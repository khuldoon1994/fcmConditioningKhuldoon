% The elastic bar problem considered in exercise 1.1

%% clear variables, close figures
clear all; %#ok
close all;

%% variables
E = 1.0;
A = 1.0;
L = 1.0;
f = @(x) sin(5*x);
c = @(x) 1+x;

p = 2;

%% problem definition
problem.name='high order fem exercise 1.1';
problem.dimension = 1;

% subelement types
subelementType1 = poCreateSubelementType( 'LEGENDRE_LINE', struct('order', p) );
problem.subelementTypes = { subelementType1 };

% element types
elementType1 = poCreateElementType( 'STANDARD_LINE_1D', struct('gaussOrder', p+1, 'youngsModulus', E, 'area', A ) );
problem.elementTypes = { elementType1 };

% nodes
problem.nodes = [ 0.0, L ];

% elements or 'quadrature supports'
problem.elementTopologies = [1];
problem.elementTypeIndices = [1];
problem.elementNodeIndices = { [ 1 2 ] };
                       
% elements or 'dof supports'
problem.subelementTopologies = [1];
problem.subelementTypeIndices = [1];
problem.subelementNodeIndices = { [ 1 2 ] };

% connections / transformations between elements and subelements
problem.elementConnections = { { { 1 1 } } };
                                   
% boundary conditions
problem.loads = { f };
problem.penalties = { [0, 1e60] };
problem.foundations = { c };

% element boundary condition connections
problem.elementLoads = { 1 };
problem.elementPenalties = { [] };
problem.elementFoundations = { 1 };

% nodal boundary condition connections
problem.nodeLoads = { [], [] };
problem.nodePenalties = { 1, [] };
problem.nodeFoundations = { [], [] };

% check and complete problem data structure
problem = poCheckProblem(problem);

% plot mesh and boundary conditions
goPlotMesh(problem,1);

%% analysis
[ allKe, allFe, allLe ] = goCreateElementMatrices( problem );

[ K, F ] = goAssembleSystem(allKe, allFe, allLe);

U = moSolveSparseSystem(K,F);

[ allUe ] = goDisassembleVector( U, allLe );

%% post processing
goPlotSolution1d( problem, allUe, 10, 2 );

%% check
URef=[1.63161792909263810e-61  -6.92460946818429790e-02  -6.79894351792358076e-02  ]';
if sum(URef==U)~=3
   disp('ERROR! Check failed!'); 
end
