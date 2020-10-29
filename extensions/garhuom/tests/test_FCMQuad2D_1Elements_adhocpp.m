
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
%digits(20);
%E = vpa(1.0);
%E = 1.0;
%mu = 0.3;
E = 206900.0;
mu = 0.29;

sizeGeom = 100.0;
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
'physics', 'PLANE_STRESS', 'youngsModulus', E, 'poissonRatio', mu));

elementType2 = poCreateFCMElementTypeLine2d( struct( ...
    'levelSetFunction', levelSetFunction, ...
    'quadratureRule', 'ADAPTIVE_GAUSS_LEGENDRE',...
    'gaussOrder', 2*p,...
    'depth', n,...
    'alphaFCM', alpha,...
'physics', 'PLANE_STRESS', 'youngsModulus', E, 'poissonRatio', mu));

problem.elementTypes = { elementType1, elementType2 };

% mesh data
problem.nodes = [ 0.0, sizeGeom ,0, sizeGeom;
                  0.0, 0.0, sizeGeom, sizeGeom ];

% 
problem.elementTopologies = [ 2 1 1 1];
problem.elementTypeIndices = [ 1 2 2 2];
problem.elementNodeIndices = {
    [ 1 2 3 4 ]
    [1 2] % penalty constraint
    [3 4] %load
    [2 4] % penalty constraint              
};

% subelement 
subelementType1 = poCreateSubelementType( 'LEGENDRE_QUAD', struct( 'order', p ) );
subelementType2 = poCreateSubelementType( 'LEGENDRE_EDGE', struct( 'order', p ) );
problem.subelementTypes = { subelementType1, subelementType2 };

% high order
problem.subelementTopologies = [ 2, 1, 1, 1, 1 ];
problem.subelementTypeIndices = [ 1, 2, 2, 2, 2];
problem.subelementNodeIndices = {
    [ 1 2 3 4 ]
    [ 1 2 ] % penalty constraint
    [ 3 4 ] %load
    [ 1 3 ]
    [ 2 4 ] % penalty constraint
};

problem = poCreateElementConnections( problem );

% boundary conditions
problem.loads = { [0 ; 450] };
penalty1 = [0, 0; 0, 1e20] ;
penalty2 =  [ 0, 1e20; 0, 0] ;
penalty3 =  [ 0, 1e20; 0, 1e20] ;
problem.penalties = { penalty1, penalty2, penalty3};
problem.foundations = { [] };

problem.elementLoads = {[],[],1,[]};
problem.elementPenalties = {[],1,[],2};
problem.elementFoundations = { [],[],[],[] };

problem.nodeLoads = { [],[],[],[]};
problem.nodePenalties = { 1,3,[],2};
problem.nodeFoundations = { [],[],[],[] };


% quadrature types
problem.elementQuadratures = poSetupElementQuadratures(problem);


% check and complete problem data structure
problem = poCheckProblem(problem);

Aq = sum( problem.elementQuadratures{1}.weights )*2500;
Aex = 100*100 - pi*(10)^2/4;

e_r = abs( (Aq - Aex) / Aex );

%% analysis
[ allKe, allFe, allLe ] = goCreateElementMatrices( problem );

[ K, F ] = goAssembleSystem(allKe, allFe, allLe);

U = K \ F;

[ allUe ] = goDisassembleVector( U, allLe );

%% conditioning number
% git the matrix of interest
ke2 = allKe{1};

% compute the eigen values
[V,eigV] = eig(ke2);
numberOfEigValuesIncludingBCs = size(eigV,1);

% remove eigen values related to BCs
indices = find(abs(eigV)>1e19);
eigV(indices) = [];

numberOfEigValuesWithoutBCs = size(eigV,1);

% compute the conditioning
minEig = min(eigV);
maxEig = max(eigV);
condition = abs(maxEig/minEig);

%% postprocess results
% plot integration points
 plotAdaptiveGaussLegendre2d( problem, 2)

% plot mesh and boundary conditions
goPlotMesh(problem,3);
goPlotLoads(problem,3, 0.03);

% plot displacement field
postGridCells = goCreatePostGrid( problem, 10 );
goPlotPostGridSolution( problem, allUe, postGridCells, @eoEvaluateSolution, @eoEvaluateSolution, 4);


%% plot eigenmodes
% V = [
%     -5.395886900641651e-01     8.909670268834106e-02    -2.755101143785899e-01    -4.993592355807723e-01    -2.530521369574032e-02     3.854276098028561e-01    -3.185051924249541e-01    -3.535533905932738e-01
%     -7.191228898920465e-02     3.829410157526459e-02     6.069284838239811e-01     2.530521369574044e-02    -4.993592355807713e-01     3.185051924249544e-01     3.854276098028563e-01    -3.535533905932737e-01
%     -5.395886900641653e-01     8.909670268834127e-02    -2.755101143785899e-01     4.993592355807717e-01     2.530521369574066e-02     3.185051924249545e-01     3.854276098028559e-01     3.535533905932737e-01
%     -3.971450860725326e-01    -4.274670612390989e-01     1.858700948621089e-01    -2.530521369574014e-02     4.993592355807721e-01    -3.854276098028564e-01     3.185051924249540e-01    -3.535533905932737e-01
%     -2.143558929808375e-01     5.548578655027051e-01     1.455482745832822e-01     4.993592355807714e-01     2.530521369574037e-02    -3.185051924249542e-01    -3.854276098028563e-01    -3.535533905932737e-01
%     -7.191228898920472e-02     3.829410157526467e-02     6.069284838239811e-01    -2.530521369574065e-02     4.993592355807718e-01     3.854276098028558e-01    -3.185051924249548e-01     3.535533905932736e-01
%     -2.143558929808373e-01     5.548578655027046e-01     1.455482745832821e-01    -4.993592355807720e-01    -2.530521369574047e-02    -3.854276098028562e-01     3.185051924249546e-01     3.535533905932740e-01
%     -3.971450860725326e-01    -4.274670612390988e-01     1.858700948621089e-01     2.530521369574050e-02    -4.993592355807723e-01    -3.185051924249541e-01    -3.854276098028561e-01     3.535533905932736e-01];


% D =[ 1.428571428571428e+00                         0                         0                         0                         0                         0                         0                         0
%                          0     7.692307692307693e-01                         0                         0                         0                         0                         0                         0
%                          0                         0     7.692307692307689e-01                         0                         0                         0                         0                         0
%                          0                         0                         0     4.945054945054944e-01                         0                         0                         0                         0
%                          0                         0                         0                         0     4.945054945054941e-01                         0                         0                         0
%                          0                         0                         0                         0                         0     4.880700421736125e-17                         0                         0
%                          0                         0                         0                         0                         0                         0     4.744076505296236e-17                         0
%                          0                         0                         0                         0                         0                         0                         0     4.112635316286080e-17 ];

% postGridCells = goCreatePostGrid( problem, 10 );
% for i=1:1:8
%     allUe{1} = V(:,i);
%     allUe{1} = allUe{1};
%     goPlotPostGridSolution( problem, allUe, postGridCells, @eoEvaluateStrain, @eoEvaluateSolution,i);
% end
