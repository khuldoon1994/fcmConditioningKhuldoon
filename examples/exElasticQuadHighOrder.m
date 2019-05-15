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

% polynomial degree
p=2;

% element types
elementType1 = poCreateElementType( 'STANDARD_QUAD_2D', struct('gaussOrder', p+1, 'physics', 'PLANE_STRAIN', 'youngsModulus', 1, 'poissonRatio', 0.3) );
elementType2 = poCreateElementType( 'STANDARD_LINE_2D', struct('gaussOrder', p+1, 'physics', 'PLANE_STRAIN', 'youngsModulus', 1, 'poissonRatio', 0.3) );
problem.elementTypes = { elementType1, elementType2 };

% nodes
problem.nodes = [ 0.0, 1.0, 0.0, 1.0;
                  0.0, 0.0, 1.0, 1.0 ];
% elements
problem.elementTopologies = [ 2 1 1 ];
problem.elementTypeIndices = [ 1 2 2 ];
problem.elementNodeIndices = {
    [ 1 2 3 4 ]    % a quad (2) of cell type (1) with nodes (1 2 3 4) - the 'main element'
    [ 1 3 ]        % needed for penalty constraint 
    [ 2 4 ]        % a line (1) of cell type (2) with nodes (2 4) - for traction integration
};

% the mesh would normally be created automatically, e.g 
% [ problem ] = poReadMesh( problem, adhocMeshFile.qua );

% subelement types
subelementType1 = poCreateSubelementType( 'LEGENDRE_QUAD', struct('order', p) );
subelementType2 = poCreateSubelementType( 'LEGENDRE_EDGE', struct('order', p) );
problem.subelementTypes = { subelementType1, subelementType2 };

% subelements
problem.subelementTopologies = [ 2, 1, 1, 1, 1 ];
problem.subelementTypeIndices = [ 1, 2, 2, 2, 2 ];
problem.subelementNodeIndices = {
    [ 1 2 3 4 ]
    [ 1 2 ]
    [ 3 4 ]
    [ 1 3 ]
    [ 2 4 ]
};

% this could be done automatically, e.g 
% problem.subelements = { problem.elements, createEdgesFromFaces(problem.elements) };    

% element connections
 problem.elementConnections = {
      { { 1 [ 1, 0; 0, 1] }
        { 2 [ 1, 0; 0,-1] }
        { 3 [ 1, 0; 0, 1] }
        { 4 [ 0, 1;-1, 0] }
        { 5 [ 0, 1; 1, 0] } }
      { { 4 [ 1, 0; 0,-1] } }
      { { 1 [ 0, 1; 1, 0] }
        { 5 [ 1, 0; 0, 1] } }      
 };

% this can be done automatically, e.g 
% problem = poCreateElementConnections( problem );


% boundary conditions
problem.loads = { [ 0.15; 0.0 ] };
problem.penalties = { [0, 1e15; 0, 1e15] };
problem.foundations = { };

% element boundary condition connections
problem.elementLoads = { [], [], 1 };
problem.elementPenalties = { [], 1, [] }; % penalty has to be enforced on edge modes
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
URef = [ 2.49999999999999995e-17  4.05379813635572236e-18  1.29564739090262893e-01  2.75437531149397494e-02  2.49999999999999964e-17 -4.05379813635572390e-18  1.29564739090262837e-01 -2.75437531149396488e-02 -1.79582654660750234e-02  1.04879893910309651e-18 -2.51227826673584885e-03 -2.43594136673668284e-02 -2.51227826673584972e-03  2.43594136673668492e-02 -5.61616373706569465e-17 -6.76407818498475892e-35 -5.37005822537547917e-03  1.23199016007926410e-17 ]';
if norm(abs(URef-U))>1e-16
   error('exElasticQuad: Check failed!');
else
    disp('exElasticQuad: Check passed.');
end
