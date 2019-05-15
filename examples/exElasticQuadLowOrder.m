%% Solves the following problem:

%            3 - 4
% penalty    |   |   traction
%            1 - 2

%% clear variables, close figures
clear all; %#ok
close all;
warning('off', 'MATLAB:nearlySingularMatrix'); % get with [a, MSGID] = lastwarn();


%% problem definition
problem.name='elasticQuad';
problem.dimension = 2;

% element types
elementType1 = poCreateElementType( 'STANDARD_QUAD_2D', struct('gaussOrder', 2, 'physics', 'PLANE_STRAIN', 'youngsModulus', 1, 'poissonRatio', 0.3) );
elementType2 = poCreateElementType( 'STANDARD_LINE_2D', struct('gaussOrder', 2, 'physics', 'PLANE_STRAIN', 'youngsModulus', 1, 'poissonRatio', 0.3) );
problem.elementTypes = { elementType1, elementType2 };

% nodes
problem.nodes = [ 0.0, 1.0, 0.0, 1.0;
                  0.0, 0.0, 1.0, 1.0 ];
% elements
problem.elementTopologies = [ 2 1 ];
problem.elementTypeIndices = [ 1 2 ];
problem.elementNodeIndices = {
    [ 1 2 3 4 ]      % a quad (2) of cell type (1) with nodes (1 2 3 4) - the 'main element'
    [ 2 4 ]          % a line (1) of cell type (2) with nodes (2 4) - for traction integration
};

% the mesh would normally be created automatically, e.g 
% [ problem ] = poReadMesh( problem, adhocMeshFile.qua );

% subelement types
subelementType1 = poCreateSubelementType( 'LINEAR_QUAD', { } );
problem.subelementTypes = { subelementType1 };

% subelements
problem.subelementTopologies = [ 2 ];
problem.subelementTypeIndices = [ 1 ];
problem.subelementNodeIndices = {
    [ 1 2 3 4 ]
};

% this could be done automatically, e.g 
% problem.subelements = { problem.elements, createEdgesFromFaces(problem.elements) };    

% element cell connection
problem.elementConnections = {
    { { 1 [ 1, 0; 0, 1] } },
    { { 1 [ 0, 1; 1, 0] } }
};

% this can be done automatically, e.g 
% problem = poCreateElementConnections( problem );


% boundary conditions
problem.loads = { [ 0.15; 0.0 ] };
problem.penalties = { [0, 1e15; 0, 1e15] };
problem.foundations = { }; %foundations added

% element boundary condition connections
problem.elementLoads = { [], 1 };
problem.elementPenalties = { [], [] };
problem.elementFoundations = { [], [], []};

% nodal boundary condition connections
problem.nodeLoads = { [],[],[],[] };
problem.nodePenalties = { 1,[],1,[] };
problem.nodeFoundations = { [],[],[] };

% check and complete problem data structure
problem = poCheckProblem(problem);

% plot mesh and boundary conditions
goPlotMesh(problem,1);
goPlotLoads(problem,1,1);
goPlotPenalties(problem,1);
title('Problem setup');
axis equal;


%% analysis
[ allKe, allFe, allLe ] = goCreateElementMatrices( problem );

[ K, F ] = goAssembleSystem(allKe, allFe, allLe);

U = K \ F;

[ allUe ] = goDisassembleVector( U, allLe );


%% post processing
postGridCells = goCreatePostGrid( problem, 5 );
figure(2);
goPlotPostGridSolution( problem, allUe, postGridCells, @eoEvaluateSolution, @eoEvaluateSolution, 2);
axis equal;
title('Displacement solution');

%% check
URef = [ 3.74999999999999992e-17  1.10655737704917998e-17  1.27868852459016469e-01  3.83606557377049601e-02  3.74999999999999992e-17 -1.10655737704918029e-17  1.27868852459016413e-01 -3.83606557377048907e-02 ]';
if norm(abs(URef-U))>1e-16
   error('exElasticQuad: Check failed!');
else
    disp('exElasticQuad: Check passed.');
end
