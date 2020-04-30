% A very simple example of an analysis script. 
% Solves the problem of an elastic bar, which is fixed on one end and
% loaded by a volume load.

%% clear variables, close figures
clear all; %#ok
close all;
warning('off', 'MATLAB:nearlySingularMatrix'); % get with [a, MSGID] = lastwarn();

%% problem definition
problem.name='pointMass';
problem.dimension = 2;

problem.dynamics.tStart = 0;
problem.dynamics.tStop = 10;
problem.dynamics.nTimeSteps = 401;

% mass and gravity
m = 2.5;
g = 9.81;

% subelement types
subelementType1 = poCreateSubelementType( 'POINT_2D', struct() );
problem.subelementTypes = { subelementType1 };

% element types
elementType1 = poCreateElementType( 'DYNAMIC_POINT_2D', struct( 'mass', m ) );
problem.elementTypes = { elementType1 };

% nodes
problem.nodes = [ 0.0; 
                  0.0 ];

% elements or 'quadrature supports'
problem.elementTopologies = [5];
problem.elementTypeIndices = [1];
problem.elementNodeIndices = { [ 1 ] };
                       
% elements or 'dof supports'
problem.subelementTopologies = [5];
problem.subelementTypeIndices = [1];
problem.subelementNodeIndices = { [1] };

% connections / transformations between elements and subelements
problem.elementConnections = { { { 1 [1] } } };
                                   
% boundary conditions
problem.loads = { [0; -m*g] };
problem.penalties = { };
problem.foundations = { };

% element boundary condition connections
problem.elementLoads = { [1] };
problem.elementPenalties = { [] };
problem.elementFoundations = { [] };

% nodal boundary condition connections
problem.nodeLoads = { [1] };
problem.nodePenalties = { [] };
problem.nodeFoundations = { [] };


% time integration parameters
problem.dynamics.timeIntegration = 'Newmark Integration';

% initialize dynamic problem
problem = poInitializeDynamicProblem(problem);

% plot mesh and boundary conditions
goPlotLoads(problem,1,1);
goPlotMesh(problem,1);
goPlotPenalties(problem,1);

%% dynamic analysis
displacementOverTime = zeros(2, problem.dynamics.nTimeSteps);
velocityOverTime = zeros(2, problem.dynamics.nTimeSteps);

% create system matrices
[ allMe, allDe, allKe, allFe, allLe ] = goCreateDynamicElementMatrices( problem );

% assemble
M = goAssembleMatrix(allMe, allLe);
D = goAssembleMatrix(allDe, allLe);
K = goAssembleMatrix(allKe, allLe);
F = goAssembleVector(allFe, allLe);

% set initial displacement and velocity
[ nTotalDof ] = goNumberOfDof(problem);
U0 = [0; 0];
V0 = [20; 30];

% compute initial acceleration
[ A0 ] = goComputeInitialAcceleration(problem, M, D, K, F, U0, V0);

% initialize values
[ U, V, A ] = newmarkInitialize(problem, U0, V0, A0);

% create effective system matrices
[ KEff ] = newmarkEffectiveSystemStiffnessMatrix(problem, M, D, K);


for timeStep = 1 : problem.dynamics.nTimeSteps
    
    % extract necessary quantities from solution
    displacementOverTime(:,timeStep) = U;
    velocityOverTime(:,timeStep) = V;

    % calculate effective force vector
    [ FEff ] = newmarkEffectiveSystemForceVector(problem, M, D, K, F, U, V, A);
    
    % solve linear system of equations (UNew = KEff \ FEff)
    UNew = moSolveSparseSystem( KEff, FEff );
    
    % calculate velocities and accelerations
    [ VNew, ANew ] = newmarkVelocityAcceleration(problem, UNew, U, V, A);
    
    % update kinematic quantities
    [ U, V, A ] = newmarkUpdateKinematics(UNew, VNew, ANew);
    
end

%% post processing
plot(displacementOverTime(1,:), displacementOverTime(2,:))
xlabel("x-position")
ylabel("y-position")