
%% clear variables, close figures
clear all %#ok
clc
close all

%format longE
%% problem definition
problem.name='FCM 2D conditioning 1 element';
problem.dimension = 2;

R=60;
X0 = 100;
Y0 = 0;

E = 50;
mu = 0.3;

alpha = 1.0e-10;
f = -0.1;
penaltVal = 1e20;

% polynomial degree
pA=4;

lengthX = 100;
lengthY = 100;

% depth
n=1;
%
levelSetFunction =  @(X) -( (X(1,:) -X0).^2 + (X(2,:) -Y0 ).^2 - R.^2);

condition = zeros(1,pA);

%% Start analysis
for p=1:pA
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

% mesh data
problem.nodes = [ 0.0, lengthX ,0, lengthX;
                  0.0, 0.0, lengthY, lengthY];



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
problem.loads = { [0 ; f] };
penalty1 = [0, 0; 0, penaltVal] ;
penalty2 =  [ 0, penaltVal; 0, 0] ;
penalty3 =  [ 0, penaltVal; 0, penaltVal] ;
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
Aex = 100*100 - pi*(R)^2/4;

e_r_area = abs( (Aq - Aex) / Aex );

%% analysis
[ allKe, allFe, allLe ] = goCreateElementMatrices( problem );

[ K, F ] = goAssembleSystem(allKe, allFe, allLe);

U = K \ F;

[ allUe ] = goDisassembleVector( U, allLe );

%% condition
%eigen = eig(K)

%ke1 = allKe{1};
ke2 = allKe{1};
% cond
%k = allKe{2}(2: end , 2: end);
%cond(k)
%condition(p) = cond(k);
%anzatz = p;
eigV = eig(ke2);
%eigV_withNoZeros = eigV(eigV~=0)

size_ = size(eigV,1);

indices = find(abs(eigV)>1e19);
eigV(indices) = [];


size_ = size_-size(eigV,1);
%eigV
minEig = min(eigV);
maxEig = max(eigV);
condition(p) = abs(maxEig/minEig);
%condition(p) = condest(K);

%condition = abs(maxEig/minEig)
%cond = cond(ke2)
%% error in energy

Uen=U'*K*U / 2;
Uref=4590.7731146;

eE_rel = abs( (Uen - Uref) / Uref );

end
%% postprocess

% plot integration points
plotAdaptiveGaussLegendre2d( problem, 1)

% plot mesh and boundary conditions
 goPlotMesh(problem,2);
% goPlotLoads(problem,2);
% view(2);
% axis equal;

% plot displacement field
postGridCells = goCreatePostGrid( problem, 20 );
goPlotPostGridSolution( problem, allUe, postGridCells, @eoEvaluateSolution, @eoEvaluateSolution, 3);

view(2)
axis equal;

poly = 1:pA;
condition

% plot conditioning number
figure(4)
semilogy(poly, condition, '-o', 'LineWidth',1.7,'MarkerSize',7)

ax = gca;
ax.FontSize = 14;  
%volumeFraction = (domain-1)/0.5;
%vF= num2str(volumeFraction);
%plotLabels{i} = append('vol. frac.: ',vF);
xlabel('polynomial degree $p$','FontSize',20, 'Interpreter','latex')
ylabel('condition number $k$','FontSize',20, 'Interpreter','latex')

legend(append('R = ',num2str(R)),'FontSize',14, 'Interpreter','latex', 'Location','northwest')
%xlim([1 pA])
%ylim([0.1 10^15])


A = zeros(4);
    A( 1, 1 ) = 4;
    A( 2, 1 ) = -1;
    A( 3, 1 ) = -1;
    A( 1, 2 ) = -1;
    A( 2, 2 ) = 4;
    A( 4, 2 ) = -1;
    A( 1, 3 ) = -1;
    A( 3, 3 ) = 4;
    A( 4, 3 ) = -1;
    A( 2, 4 ) = -1;
    A( 3, 4 ) = -1;
    A( 4, 4 ) = 4
    %A( 5, 5 ) = 8
