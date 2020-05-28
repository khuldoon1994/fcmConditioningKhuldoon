% A very simple example of an analysis script. 
% Solves the problem of an elastic bar, which is fixed on one end and
% loaded by a volume load.

%% clear variables, close figures
clear all; %#ok
close all;
warning('off', 'MATLAB:nearlySingularMatrix'); % get with [a, MSGID] = lastwarn();

%% problem definition
problem.name='truss2D';
problem.dimension = 2;

% parameter
rho = 1;
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
    'area', A, ...
    'massDensity', rho));
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

% time integration parameters
problem.dynamics.timeIntegration = 'Newmark Integration';
problem.dynamics.time = 0;
problem.dynamics.tStart = 0;
problem.dynamics.tStop = 10;
problem.dynamics.nTimeSteps = 5;

% initialize dynamic problem
problem = poInitializeDynamicProblem(problem);

% plot mesh and boundary conditions
goPlotLoads(problem, 1, 1);
goPlotMesh(problem, 1);
goPlotPenalties(problem, 1);


%% dynamic analysis
% create system matrices
[ allMe, allDe, allKe, allFe, allLe ] = goCreateDynamicElementMatrices( problem );

% assemble
M = goAssembleMatrix(allMe, allLe);
D = goAssembleMatrix(allDe, allLe);
K = goAssembleMatrix(allKe, allLe);
F = goAssembleVector(allFe, allLe);

% add nodal forces
Fn = goCreateNodalLoadVector(problem);
F = F + Fn;

% compute penalty stiffness matrix and penalty load vector
[ Kp, Fp ] = goCreateAndAssemblePenaltyMatrices(problem);

% set initial displacement and velocity
[ nTotalDof ] = goNumberOfDof(problem);
U0Dynamic = zeros(nTotalDof, 1);
V0Dynamic = zeros(nTotalDof, 1);

% compute initial acceleration
[ A0Dynamic ] = goComputeInitialAcceleration(problem, M, D, K, F, U0Dynamic, V0Dynamic);

% initialize values
[ UOldDynamic, UDynamic ] = cdmInitialize(problem, U0Dynamic, V0Dynamic, A0Dynamic);

% create effective system matrices
[ KEff ] = cdmEffectiveSystemStiffnessMatrix(problem, M, D, K);

% ... and add penalty constraints
KEff = KEff + Kp;

% solution quantity
displacement = zeros(nTotalDof, problem.dynamics.nTimeSteps);


for timeStep = 1 : problem.dynamics.nTimeSteps
    
    % extract necessary quantities from solution
    displacement(:,timeStep) = UDynamic;
    
    % calculate effective force vector
    [ FEff ] = cdmEffectiveSystemForceVector(problem, M, D, K, F, UDynamic, UOldDynamic);
    
    % ... and add penalty constraints
    FEff = FEff + Fp;
    
    % solve linear system of equations (UNewDynamic = KEff \ FEff)
    UNewDynamic = moSolveSparseSystem( KEff, FEff );
    
    % calculate velocities and accelerations
    [ VDynamic, ADynamic ] = cdmVelocityAcceleration(problem, UNewDynamic, UDynamic, UOldDynamic);
    
    % update kinematic quantities
    [ UDynamic, UOldDynamic ] = cdmUpdateKinematics(UNewDynamic, UDynamic);
    
end

% disassemble
[ allUe ] = goDisassembleVector( UDynamic, allLe );


%% post processing
% animation

