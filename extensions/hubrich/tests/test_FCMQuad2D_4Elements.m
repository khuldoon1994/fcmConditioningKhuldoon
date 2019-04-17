
%% clear variables, close figures
clear all %#ok
clc
close all


%% problem definition
problem.name='FCM Test 2D 4 Elements';
problem.dimension = 2;

%%
physicalDomainTestFunction =  @(X)- ( (X(1,:) -100).^2 + (X(2,:) ).^2 - 10.^2);


% polynomial degree
p=10;
% depth
n=4;

% cell types
elementType1 = poCreateFCMElementTypeQuad2d( {'physicalDomain',physicalDomainTestFunction,'adaptiveGaussLegendre', 2*p, 'depth' , n ,'alphaFCM',0.0, 'physics', 'PLANE_STRAIN', 'youngsModulus', 206900 'poissonRatio', 0.29 });
elementType2 = poCreateFCMElementTypeLine2d( {'physicalDomain',physicalDomainTestFunction,'adaptiveGaussLegendre', 2*p, 'depth' , n ,'alphaFCM',0.0, 'physics', 'PLANE_STRAIN', 'youngsModulus', 206900, 'poissonRatio', 0.29 });
problem.elementTypes = { elementType1, elementType2 };

problem.nodes=[ 0 50 100 0 50 100 0 50 100; 0 0 0 50 50 50 100 100 100 ];

problem.elementNodeIndices = { [ 1 2 4 5 ], [ 2 3 5 6 ],[4 5 7 8], [5 6 8 9],[1 2],[2 3],[3 6], [6 9] ,[7 8],[8 9] };
problem.elementTopologies = [ 2 2 2 2 1 1 1 1 1 1];
problem.elementTypeIndices = [ 1 1 1 1 2 2 2 2 2 2];

% subelement 
subelementType1 = poCreateSubelementType( 'LEGENDRE_QUAD', { 'order', p } );
subelementType2 = poCreateSubelementType( 'LEGENDRE_EDGE', { 'order', p } );
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
problem.loads = { [0 ; 450] };
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
problem = poSetupElementQuadratures(problem);

%% check and complete problem data structure

problem = poCheckProblem(problem);

Aq = sum( [problem.elementQuadratures{1}.weights,problem.elementQuadratures{2}.weights,problem.elementQuadratures{3}.weights, problem.elementQuadratures{4}.weights] )*2500/4;
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
goPlotMesh(problem,2);
goPlotLoads(problem,2);
view(2);
axis equal;

% plot displacement field
postGridCells = goCreatePostGrid( problem, 10 );
goPlotPostGridSolution( problem, allUe, postGridCells, @eoEvaluateSolution, @eoEvaluateSolution, 3);

view(2)
axis equal;
