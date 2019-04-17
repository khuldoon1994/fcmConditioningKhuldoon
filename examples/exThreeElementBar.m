% A simple one dimensional problem.

%% clear variables, close figures
clear all; %#ok
close all;
warning('off', 'MATLAB:nearlySingularMatrix'); % get with [a, MSGID] = lastwarn();


%% problem definition
problem.name='elasticBar';
problem.dimension = 1;

% nodes
problem.nodes = [ 0.0, 1.0, 2.0, 3.0 ];

% element types
elementType1 = poCreateElementType( 'STANDARD_LINE_1D', struct('gaussOrder', 3, 'youngsModulus', 1.0, 'area', 1.0) );
problem.elementTypes = { elementType1 };

% elements or 'quadrature supports'
problem.elementNodeIndices = { [ 1 2 ], [ 2 3 ], [ 3 4 ] };
problem.elementTypeIndices = [ 1 1 1 ];
problem.elementTopologies = [ 1 1 1 ];

% subelement types
%subelementType1 = createElementType( 'LINEAR_LINE', { } );
subelementType1 = poCreateSubelementType( 'LEGENDRE_LINE', struct('order', 2) );
problem.subelementTypes = { subelementType1 };

% subelements or 'dof supports'
problem.subelementNodeIndices = { [ 1 2 ], [ 2 3 ], [ 3 4 ] };
problem.subelementTypeIndices = [ 1 1 1 ];
problem.subelementTopologies = [ 1 1 1 ];
                  
% connection / transformation between elements and subelements
problem = poCreateElementConnections( problem );

% boundary conditions
problem.loads = { 1.5 };
problem.penalties = { [0, 1e60] };

% element boundary condition connections
problem.elementLoads = { 1 1 1 };
problem.elementPenalties = { [], [], [] };
problem.elementFoundations = { [], [], [] };

% nodal boundary condition connections
problem.nodeLoads = { [],[],[],[] };
problem.nodePenalties = { 1,[],[],[] };
problem.nodeFoundations = { [], [], [], [] };

% check and complete problem data structure
problem = poCheckProblem(problem);

% plot mesh and boundary conditions
goPlotMesh(problem,1);
% plotShapeFunction( problem , 1, 1 );

%% analysis
[ allKe, allFe, allLe ] = goCreateElementMatrices( problem );
[ allUe ]  = goAssembleSolveDisassemble(allKe, allFe, allLe);

%% post processing
goPlotSolution1d( problem, allUe, 10, 2 );

URef=[4.50000000000000001e-60  3.75000000000000000e+00 -3.06186217847897235e-01 3.75000000000000000e+00  6.00000000000000000e+00 -3.06186217847897235e-01 6.00000000000000000e+00  6.74999999999999911e+00 -3.06186217847897235e-01]'; 
if sum(URef==[allUe{1}; allUe{2}; allUe{3}])~=numel(URef)
   error('exThreeElementBar: Check failed!'); 
else
   disp('exThreeElementBar: Check passesd.'); 
end
