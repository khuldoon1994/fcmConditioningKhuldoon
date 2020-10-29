
%% clear variables, close figures
clear all %#ok
clc
close all

format longE;

%% problem definition
problem.name='FCM Test 2D 4 Elements conditioning';
problem.dimension = 2;

%% parameters
% polynomial degree
p= 7;

% integration depth
n=5;

% material
%digits(15);
%E = vpa(206900.0);
E = 206900.0;
mu = 0.29;

alpha = 0;
load = 450;

%level set
R = 60;
X0 = 100;
Y0 = 0;
levelSetFunction =  @(X) -( (X(1,:) -X0).^2 + (X(2,:) -Y0 ).^2 - R.^2);

% stablization parameters
problem.stablization.epsilon = 1.0e-4;
problem.stablization.tolerenceEig = 1.0e-1;
problem.stablization.tolerenceStrain = 1.0e-6;

%% Start analysis
% cell types 
elementType1 = poCreateFCMElementTypeQuad2d( struct( ...
    'levelSetFunction', levelSetFunction, ...
    'quadratureRule', 'ADAPTIVE_GAUSS_LEGENDRE',...
    'gaussOrder', 2*p,...
    'depth', n,...
    'alphaFCM', alpha,...
'physics', 'PLANE_STRAIN', 'youngsModulus', E, 'poissonRatio', mu));

elementType2 = poCreateFCMElementTypeLine2d( struct( ...
    'levelSetFunction', levelSetFunction, ...
    'quadratureRule', 'ADAPTIVE_GAUSS_LEGENDRE',...
    'gaussOrder', 2*p,...
    'depth', n,...
    'alphaFCM', alpha,...
'physics', 'PLANE_STRAIN', 'youngsModulus', E, 'poissonRatio', mu));

problem.elementTypes = { elementType1, elementType2 };

problem.nodes=[ 0 50 100 0 50 100 0 50 100;
                0 0 0 50 50 50 100 100 100 ];

problem.elementNodeIndices = { [ 1 2 4 5 ], [ 2 3 5 6 ],[4 5 7 8], [5 6 8 9],[1 2],[2 3],[3 6], [6 9] ,[7 8],[8 9] };
problem.elementTopologies = [ 2 2 2 2 1 1 1 1 1 1];
problem.elementTypeIndices = [ 1 1 1 1 2 2 2 2 2 2];

% subelement 
subelementType1 = poCreateSubelementType( 'LEGENDRE_QUAD', struct( 'order', p ) );
subelementType2 = poCreateSubelementType( 'LEGENDRE_EDGE', struct( 'order', p ) );
problem.subelementTypes = { subelementType1, subelementType2 };

problem.subelementNodeIndices = { [ 1 2 4 5 ]
    [ 2 3 5 6 ]
    [4 5 7 8]
    [5 6 8 9]
    [1 2]
    [1 4]
    [2 3]
    [2 5]
    [3 6]
    [4 5]
    [4 7] 
    [5 6]
    [5 8]
    [6 9] 
    [7 8]
    [8 9] };
problem.subelementTopologies = [ 2 2 2 2 1 1 1 1 1 1 1 1 1 1 1 1];
problem.subelementTypeIndices = [ 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2];

problem = poCreateElementConnections( problem );

  % boundary conditions
problem.loads = { [0 ; load] };
penalty1 = [0, 0; 0, 1e20] ; %no movement in y
penalty2 =  [ 0, 1e20; 0, 0] ; %no movement in x
penalty3 =  [ 0, 1e20; 0, 1e20] ;
problem.penalties = { penalty1, penalty2, penalty3};
problem.foundations = { [] };

problem.elementLoads = {[],[],[],[],[],[],[],[],1,1};
problem.elementPenalties = {[],[],[],[],1 ,1, 2 ,2,[],[],};
problem.elementFoundations = { [],[],[],[],[],[],[],[],[],[] };

problem.nodeLoads = { [],[],[],[],[],[],[],[],[]};

problem.nodePenalties = { 1,1,3,[],[],2,[],[],2};
problem.nodeFoundations = { [],[],[],[],[],[],[],[],[],[] };

% quadrature types
problem.elementQuadratures = poSetupElementQuadratures(problem);

% check and complete problem data structure
problem = poCheckProblem(problem);

%% integration error
Aq = sum( [problem.elementQuadratures{1}.weights,problem.elementQuadratures{2}.weights,problem.elementQuadratures{3}.weights, problem.elementQuadratures{4}.weights] )*2500/4;
Aex = 100*100 - pi*(R)^2/4;

relativeErrorIntegration = abs( (Aq - Aex) / Aex )

%% analysis
[ allKe, allFe, allLe ] = goCreateElementMatrices( problem );

[ K, F ] = goAssembleSystem(allKe, allFe, allLe);

U = K \ F;

[ allUe ] = goDisassembleVector( U, allLe );

%% conditioning number

% git the matrix of interest
ke2 = allKe{1};
%ke2 = full(K);

% compute the eigen values
eigV = eig(ke2);
numberOfEigValuesIncludingBCs = size(eigV,1);

% remove eigen values related to BCs
indices = find(abs(eigV)>1e19);
eigV(indices) = [];

numberOfEigValuesWithoutBCs = size(eigV,1);
%eigV

% compute the conditioning
minEig = min(eigV);
maxEig = max(eigV);
condition = abs(maxEig/minEig);

% those function can't be used directly because of the BCs 
% condition_condest = condest(ke2);
% condition_cond = cond(ke2, 'fro')

% leg = legend(leg) ;
% set(leg,'Location','northwest')

%% postprocess results
% plot integration points
plotAdaptiveGaussLegendre2d( problem, 2)

% plot mesh and boundary conditions
%goPlotMesh(problem,3);
%goPlotLoads(problem,3, 0.03);
%view(2);
%axis equal;

% plot displacement field
postGridCells = goCreatePostGrid( problem, 10 );
goPlotPostGridSolution( problem, allUe, postGridCells, @eoEvaluateSolution, @eoEvaluateSolution, 4);

%view(3)
%axis equal;

%% checks
energy_adhocpp = 1.911685102607921E+04;
condition_adhocpp = 3.0016147107e+05;

%% error in energy

% Uen=U'*K*U / 2;
% 
% relativeErrorEnergy = abs( (Uen - energy_adhocpp) / energy_adhocpp )
% relativeErrorCondition = abs( (condition - condition_adhocpp) / condition_adhocpp )
% 
% if relativeErrorEnergy>1e-13
%    error('exElasticBarFCM: Energy check failed!');
% else
%    disp('exElasticBarFCM: Energy check passed.');
% end
% 
% if relativeErrorCondition>1e-3
%    error('exElasticBarFCM: Condition check failed!');
% else
%    disp('exElasticBarFCM: Condition check passed.');
% end

%% singular value decomposition

%s = svd(ke2)
%s_ = eig(ke2)

% try chol(ke2);
%     disp('Matrix is symmetric positive definite.')
% catch ME
%     disp('Matrix is not symmetric positive definite')
% end

%condition

%isSym = issymmetric(ke2)