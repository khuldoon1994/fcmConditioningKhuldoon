% SiHoFemLab - Step 3
% As in step 1, a problem structure will be set up in this step. This time,
% the problem consists of ractangle, which is clamped at one end  andloaded
% by a surface straction on the other end. The rectangle is 1 by 2 meters
% and should behave according plane strain physics with a Youngs modulus of
% E=1, Poisson ration nu=0.3.

%      _____________________
%    /|                     |--->
%    /|                     |--->
%    /|                     |--->   t
%    /|                     |---> 
%    /|_____________________|--->
%

%% clear variables, close figures
clear all; %#ok
close all;

%% setup problem
% We start again with the name and the dimension
problem.name='elastic quad';
problem.dimension = 2;

% Next, we define 6 nodes, such taht the rectangle can be discretized by two
% quadrilateral elements.
problem.nodes=[0 1 2 0 1 2;
               0 0 0 1 1 1];

% Here are the element types. We need one for the quadrilaterals and one
% for the right edge, where we have to integrate the surface traction t.
elementType1 = poCreateElementType( 'STANDARD_QUAD_2D', struct('gaussOrder', 3, 'physics', 'PLANE_STRAIN', 'youngsModulus', 1, 'poissonRatio', 0.3) );
elementType2 = poCreateElementType( 'STANDARD_LINE_2D', struct('gaussOrder', 3, 'physics', 'PLANE_STRAIN', 'youngsModulus', 1, 'poissonRatio', 0.3) );
problem.elementTypes = { elementType1, elementType2 };

% Now we need subelement types. Each quadrilateral should use high-order
% shape functions, which are commonly devided into nodal modes, edge modes
% and internal modes. In SiHoFemLab, nodal and internal modes are always 
% combined in an element type but the edge modes (and face modes in 3d) are
% provided by extra element types:
subelementType1 = poCreateSubelementType( 'LEGENDRE_QUAD', struct('order', 2) );
subelementType2 = poCreateSubelementType( 'LEGENDRE_EDGE', struct('order', 2) );
problem.subelementTypes = { subelementType1, subelementType2 };

% Each quadrliateral element will be connected to five subelements, one of
% type LEGENDRE_QUAD and four of type LEGENDRE_EDGE. The type LEGENDRE_EDGE
% provides the edge modes and does not have its own nodal modes.

% Ok, here are the element definitions:
problem.elementNodeIndices = { [ 1 2 4 5 ], [ 2 3 5 6 ], [ 3 6 ], [ 1 4] };
problem.elementTopologies = [ 2 2 1 1 ];
problem.elementTypeIndices = [ 1 1 2 2 ];

% And here are the subelement definitions:
problem.subelementNodeIndices = { [ 1 2 4 5 ], [ 2 3 5 6 ], [1 2], [2 3], [4 5], [5 6], [1 4], [2 5], [3 6] };
problem.subelementTopologies = [ 2 2 1 1 1 1 1 1 1 ];
problem.subelementTypeIndices = [ 1 1 2 2 2 2 2 2 2 ];

% Again, we will create the connections between elements and subelements
% automatically:
problem = poCreateElementConnections( problem );

% Loads are defined as in the one-dimensional case, but with two dimensions
% now, one in each row:
problem.loads = { [ 0.15; 0.0 ] };
problem.penalties = { [0, 1e60; 0, 1e60] };

% Again, elements and nodes have to be connected to the boundary
% conditions.
problem.elementLoads = { [] [] 1 [] };
problem.elementPenalties = { [] [] [] 1 };
problem.elementFoundations = { [] [] [] [] };
problem.nodeLoads = { [],[],[],[],[],[] };
problem.nodePenalties = { 1,[],[],1,[],[] };
problem.nodeFoundations = { [],[],[],[],[],[] };


% From here on, everythign is the same as in step 2. Check, plot, assemble,
% disassemble...

% check
poCheckProblem(problem);

% plot
goPlotMesh(problem,1);
goPlotLoads(problem,1,1.0);
goPlotPenalties(problem,1);
axis equal;

% create system matrices
[ allKe, allFe, allLe ] = goCreateElementMatrices( problem );

% assemble
[ K, F ] = goAssembleSystem(allKe, allFe, allLe);

% solve
U = K \ F;

% disassemble
[ allUe ] = goDisassembleVector( U, allLe );


% postprocess
postGridCells = goCreatePostGrid( problem, 10 );
%goPlotPostGrid( problem, postGridCells, 2);
goPlotPostGridSolution( problem, allUe, postGridCells, @eoEvaluateSolution, @eoEvaluateSolution, 2);

%plotPostGrid( problem, allUe, postGridCells, @basicSolutionCalculator, @basicSolutionCalculator, 2);

axis equal;
view(2);
