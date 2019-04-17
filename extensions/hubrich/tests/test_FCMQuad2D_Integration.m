
%% clear variables, close figures
clear
clc
close all


%% problem definition
problem.name='FCM Test 2D';
problem.dimension = 2;

%%
physicalDomainTestFunction =  @(X) -( (X(1,:) -100).^2 + (X(2,:) ).^2 - 50.^2);


% polynomial degree
p=1;
% depth
n=3;


quadratureType.depth = n;
quadratureType.order = p;
%quadratureType.alphaFCM = 0.0;


% cell types
elementType1 = poCreateFCMElementTypeQuad2d( {'physicalDomain',physicalDomainTestFunction,'adaptiveGaussLegendre', 2*p, 'depth' , n ,'alphaFCM',1.0, 'physics', 'PLANE_STRAIN', 'youngsModulus', 206900, 'poissonRatio', 0.29 });
elementType2 = poCreateFCMElementTypeLine2d( {'physicalDomain',physicalDomainTestFunction,'adaptiveGaussLegendre', 2*p, 'depth' , n ,'alphaFCM',0.0, 'physics', 'PLANE_STRAIN', 'youngsModulus', 206900, 'poissonRatio', 0.29 });
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
subelementType1 = poCreateSubelementType( 'LEGENDRE_QUAD', { 'order', p } );
subelementType2 = poCreateSubelementType( 'LEGENDRE_EDGE', { 'order', p } );
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


%problem = poCreateElementConnections( problem );
% %Manual Element connections
problem.elementConnections = {
    { { 1 [ 1, 0; 0, 1] }
      { 2 [ 1, 0; 0,-1] }
      { 3 [ 1, 0; 0, 1] }
      { 4 [ 0, -1;+1, 0] }
      { 5 [ 0, 1; 1, 0] } }
      {{ 2 [0 1;-1 0]}}
     {{1 [ 0, 1; 1, 0]}
      {3 [ 0, 1; 1, 0]}}
      {{5 [ 1 0; 0 1 ]}}
      };


% boundary conditions
problem.loads = { [0 ; 450] };
penalty1 = [0, 0; 0, 1e15] ; %no movement in y
penalty2 =  [ 0, 1e15; 0, 0] ; %no movement in x
penalty3 =  [ 0, 1e15; 0, 1e15] ;
problem.penalties = { penalty1, penalty2, penalty3};
problem.foundations = { [] };

problem.elementLoads = {[],[],1,[]};
problem.elementPenalties = {[],1,[],2};
problem.elementFoundations = { [],[],[],[] };

problem.nodeLoads = { [],[],1,1};
problem.nodePenalties = { 1,3,[],2};
problem.nodeFoundations = { [],[],[],[] };


% quadrature types

problem = poSetupElementQuadratures(problem);

% check and complete problem data structure
problem = poCheckProblem(problem);

% plot mesh and boundary conditions
goPlotMesh(problem,1);
plotLoads(problem,1);
view(3);
axis equal;

% Setup GaussLegrendeQuadTreePlot
problem = eoSetupAdaptiveGaussLegendre2d( problem, 1 );

plotAdaptiveGaussLegendre2d( problem, 2) 

Aq = sum( problem.elementQuadratures{1}.weights )*2500
Aex = 100*100 - pi*(10)^2/4

e_r = abs( (Aq - Aex) / Aex )


%% analysis
[ allKe, allFe, allLe ] = goCreateElementMatrices( problem );

[ K, F ] = goAssembleSystem(allKe, allFe, allLe);

U = K \ F;

[ allUe ] = goDisassembleVector( U, allLe );


%
%plotSolutionOverMesh2d( problem, allUe, 10, 2 );


%% post processing
postGridCells = goCreatePostGrid( problem, 5 );
%plotPostGrid( problem, allUe, postGridCells, @eoEvaluateSolution, @eoEvaluateSolution, 2);
%view(3)
%axis equal;

% % Energy
Uen=U'*K*U;
Uref=4590.7731146;
