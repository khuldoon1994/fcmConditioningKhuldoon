% The elastic bar problem considered in exercise 2.1

%% clear variables, close figures
clear all; %#ok
close all;

%% variables
E = 1.0;
A = 1.0;
L = 1.0;
f = @(x) 0.1*(1-x/L);
ref = @(x) x.^3/60 - x.^2/20 + x/20;

p = 1;

%% problem definition
problem.name='high order fem exercise 2.1';
problem.dimension = 1;

% subelement types
subelementType1 = poCreateSubelementType( 'LEGENDRE_LINE', struct('order', p) );
problem.subelementTypes = { subelementType1 };

% element types
elementType1 = poCreateElementType( 'STANDARD_LINE_1D', struct('gaussOrder', p+1, 'youngsModulus', E, 'area', A) );
problem.elementTypes = { elementType1 };

% nodes
problem.nodes = [ 0.0, 0.5*L, L ];

% elements or 'quadrature supports'
problem.elementTopologies = [1 1];
problem.elementTypeIndices = [1 1];
problem.elementNodeIndices = { [ 1 2 ], [2 3] };
                       
% subelements or 'dof supports'
problem.subelementTopologies = [1,1];
problem.subelementTypeIndices = [1,1];
problem.subelementNodeIndices = { [ 1 2 ], [ 2 3 ] };

% connections / transformations between elements and subelements
problem.elementConnections = { { { 1 1 } }, { { 2 1 } } };
                                   
% boundary conditions
problem.loads = { f };
problem.penalties = { [0, 1e60] };
problem.foundations = { };

% element boundary condition connections
problem.elementLoads = { 1, 1 };
problem.elementPenalties = { [], [] };
problem.elementFoundations = { [], [] };

% nodal boundary condition connections
problem.nodeLoads = { [], [], [] };
problem.nodePenalties = { 1, [], [] };
problem.nodeFoundations = { [], [], [] };

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
subplot(2,2,1);
x=linspace(0,L,20);
y=ref(x);
plot(x,y,'k-');



%% check
URef=[ 5.00000000000000020e-62  1.45833333333333353e-02  1.66666666666666699e-02 ]';
if sum(URef==U)~=numel(U)
   disp('ERROR! Check failed!'); 
end
