
%% clear variables, close figures
clear all %#ok
clc
close all


%% problem definition
problem.name='FCM Test 2D';
problem.dimension = 2;

%%
levelSetFunction =  @(X) -( (X(1,:) -100).^2 + (X(2,:) ).^2 - 10.^2);


% polynomial degree
p=3;
% depth
n=3;

% cell types
elementType1 = poCreateFCMElementTypeQuad2d( struct( ...
    'levelSetFunction', levelSetFunction, ...
    'quadratureRule', 'ADAPTIVE_GAUSS_LEGENDRE',...
    'gaussOrder', 2*p,...
    'depth', n,...
    'alphaFCM', 1.0e-016,...
'physics', 'PLANE_STRAIN', 'youngsModulus', 206900, 'poissonRatio', 0.29));
elementType2 = poCreateFCMElementTypeLine2d( struct( ...
    'levelSetFunction', levelSetFunction, ...
    'quadratureRule', 'ADAPTIVE_GAUSS_LEGENDRE',...
    'gaussOrder', 2*p,...
    'depth', n,...
    'alphaFCM', 1.0e-016,...
'physics', 'PLANE_STRAIN', 'youngsModulus', 206900, 'poissonRatio', 0.29));
problem.elementTypes = { elementType1, elementType2 };

% mesh data
problem.nodes = [ 0.0, 100.0 ,0, 100.0;
                  0.0, 0.0, 100, 100.0 ];



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

%% error in energy

Uen=U'*K*U / 2
Uref=4590.7731146

eE_rel = abs( (Uen - Uref) / Uref )

%% postprocess

% plot integration points
plotAdaptiveGaussLegendre2d( problem, 1)

% plot mesh and boundary conditions
% goPlotMesh(problem,2);
% goPlotLoads(problem,2);
% view(2);
% axis equal;

% plot displacement field
postGridCells = goCreatePostGrid( problem, 10 );
goPlotPostGridSolution( problem, allUe, postGridCells, @eoEvaluateSolution, @eoEvaluateSolution, 3);

view(2)
axis equal;
