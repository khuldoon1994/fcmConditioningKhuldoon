% A very simple example of an analysis script. 
% Solves the problem of an elastic bar, which is fixed on one end and
% loaded by a volume load.

%% clear variables, close figures
clear all; %#ok
close all;
warning('off', 'MATLAB:nearlySingularMatrix'); % get with [a, MSGID] = lastwarn();

%% problem definition
problem.name='trussSystem2D';
problem.dimension = 2;

problem.dynamics.time = 0;
problem.dynamics.tStart = 0;
problem.dynamics.tStop = 10;
problem.dynamics.nTimeSteps = 401;

% parameter
E = 1;
A = 1;

% damping parameter
problem.dynamics.massCoeff = 0.0;
problem.dynamics.stiffCoeff = 0.0;

% subelement types
subelementType1 = poCreateSubelementType( 'LINEAR_LINE', struct() );
problem.subelementTypes = { subelementType1 };

% element types
elementType1 = poCreateElementType( 'STANDARD_TRUSS_2D', struct(...
    'youngsModulus', E, ...
    'area', A));
problem.elementTypes = { elementType1 };

% nodes
problem.nodes = [ 0.0 1.0 1.0; 
                  0.0 0.0 1.0 ];

% elements or 'quadrature supports'
problem.elementTopologies = [1, 1, 1];
problem.elementTypeIndices = [1, 1, 1];
problem.elementNodeIndices = { [1 2], [2 3], [1 3] };
                       
% elements or 'dof supports'
problem.subelementTopologies = [1, 1, 1];
problem.subelementTypeIndices = [1, 1, 1];
problem.subelementNodeIndices = { [1 2], [2 3], [1 3] };

% connections / transformations between elements and subelements
problem = poCreateElementConnections( problem );
                            
% loads and boundary conditions
problem.loads = { [0.2; 0.1] };
problem.penalties = { [0, 1e60;
                       0, 1e60],
                      [0, 0;
                       0, 1e60] };
problem.foundations = { };

% element loads and boundary conditions
problem.elementLoads = { [], [], [] };
problem.elementPenalties = { [], [], [] };
problem.elementFoundations = { [], [], [] };

% nodal loads and boundary conditions
problem.nodeLoads = { [], [], [1] };
problem.nodePenalties = { [1], [2], [] };
problem.nodeFoundations = { [], [], [] };

% check problem
problem = poCheckProblem(problem);

% plot mesh and boundary conditions
goPlotLoads(problem, 1, 1);
goPlotMesh(problem, 1);
goPlotPenalties(problem, 1);

%% analysis
% create system matrices
[ allKe, allFe, allLe ] = goCreateElementMatrices( problem );

% assemble
K = goAssembleMatrix(allKe, allLe);
F = goAssembleVector(allFe, allLe);

% add nodal forces
Fn = goCreateNodalLoadVector(problem);
F = F + Fn;

% add penalty constraints
[ Kp, Fp ] = goCreateAndAssemblePenaltyMatrices(problem);
K = K + Kp;
F = F + Fp;

% solve
U = K\F;

% disassemble
[ allUe ] = goDisassembleVector( U, allLe );

%% post processing
goPlotDisplacementArrows2d(problem, U, 1);

% todo: plot deformed mesh


%% check
URef=[0, 0, 0, 0, 0.1+sqrt(2)*2/5, -0.1]';
if norm(URef-U) > 1e-12
   error('exTruss2d: Check failed!'); 
else
   disp('exTruss2d: Check passed.'); 
end

