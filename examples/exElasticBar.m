% A very simple example of an analysis script. 
% Solves the problem of an elastic bar, which is fixed on one end and
% loaded by a volume load.

%% clear variables, close figures
clear all; %#ok
close all;
warning('off', 'MATLAB:nearlySingularMatrix'); % get with [a, MSGID] = lastwarn();

%% problem definition
problem.name='elasticBar';
problem.dimension = 1;

% subelement types
subelementType1 = poCreateSubelementType( 'LEGENDRE_LINE', struct( 'order', 2 ) );
problem.subelementTypes = { subelementType1 };

% element types
elementType1 = poCreateElementType( 'STANDARD_LINE_1D', struct('gaussOrder', 3, 'youngsModulus', 1, 'area', 1.0 ) );
problem.elementTypes = { elementType1 };

% nodes
problem.nodes = [ 0.0, 1.0 ];

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
problem.loads = { 1.5 };
problem.penalties = { [0, 1e60] };
problem.foundations = { };

% element boundary condition connections
problem.elementLoads = { 1 };
problem.elementPenalties = { [] };
problem.elementFoundations = { [] };

% nodal boundary condition connections
problem.nodeLoads = { [],[] };
problem.nodePenalties = { 1,[] };
problem.nodeFoundations = { [], [] };

% check and complete problem data structure
problem = poCheckProblem(problem);

% plot mesh and boundary conditions
goPlotLoads(problem,1,0.1);
goPlotMesh(problem,1);
goPlotPenalties(problem,1);

%% analysis
[ allKe, allFe, allLe ] = goCreateElementMatrices( problem );

[ K, F ] = goAssembleSystem(allKe, allFe, allLe);

U = K \ F;

[ allUe ] = goDisassembleVector( U, allLe );

%% post processing
goPlotSolution1d( problem, allUe, 10, 2 );

%% check
URef=[1.50000000000000009e-60   7.50000000000000000e-01  -3.06186217847897235e-01]';
if sum(URef==U)~=3
   error('exElasticBar: Check failed!'); 
else
   disp('exElasticBar: Check passed.'); 
end
