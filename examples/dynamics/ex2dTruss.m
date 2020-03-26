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

% material and structure
m = 2.5;
E = 1;
A = 1;
rho = 1;
kappa = 0;

% gravity
g = 9.81;

% subelement types
subelementType1 = poCreateSubelementType( 'LINEAR_LINE', struct() );
problem.subelementTypes = { subelementType1 };

% element types
elementType1 = poCreateElementType( 'DYNAMIC_TRUSS_2D', struct(...
    'youngsModulus', E, ...
    'area', A, ...
    'massDensity', rho, ...
    'dampingCoefficient', kappa));
problem.elementTypes = { elementType1 };

% nodes
problem.nodes = [ 0.0 2.5; 
                  0.0 1.5];

% elements or 'quadrature supports'
problem.elementTopologies = [1];
problem.elementTypeIndices = [1];
problem.elementNodeIndices = { [1 2] };
                       
% elements or 'dof supports'
problem.subelementTopologies = [1];
problem.subelementTypeIndices = [1];
problem.subelementNodeIndices = { [1 2] };

% connections / transformations between elements and subelements
problem.elementConnections = { { { 1 [1] } } };
                                   
% boundary conditions
problem.loads = { [0; -m*g] };
problem.penalties = { };
problem.foundations = { };

% element boundary condition connections
problem.elementLoads = { [] };
problem.elementPenalties = { [] };
problem.elementFoundations = { [] };

% nodal boundary condition connections
problem.nodeLoads = { [1], [1] };
problem.nodePenalties = { [], [] };
problem.nodeFoundations = { [], [] };


% time integration parameters
% TODO: Rename 'Newmark Integration' to 'NEWMARK', similar for CDM
problem.dynamics.timeIntegration = 'Newmark Integration';
% TODO: Rename 'No Lumping' to 'OFF'
problem.dynamics.lumping = 'No Lumping';

% initialize dynamic problem
problem = poInitializeDynamicProblem(problem);

% plot mesh and boundary conditions
goPlotLoads(problem,1,1);
goPlotMesh(problem,1);
goPlotPenalties(problem,1);

%% dynamic analysis
displacementOverTime = zeros(4, problem.dynamics.nTimeSteps);
velocityOverTime = zeros(4, problem.dynamics.nTimeSteps);

% create system matrices
[ allMe, allDe, allKe, allFe, allLe ] = goCreateDynamicElementMatrices( problem );

% assemble
M = goAssembleMatrix(allMe, allLe);
D = goAssembleMatrix(allDe, allLe);
K = goAssembleMatrix(allKe, allLe);
F = goAssembleVector(allFe, allLe);

% set initial displacement and velocity
[ nTotalDof ] = goNumberOfDof(problem);
U0 = zeros(4,1)
V0 = zeros(4,1)

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

%% check
URef=[2.00499999999507537e+02 -1.93864452500081171e+0]';
if sum(URef==U)==3
   error('exElasticBar: Check failed!'); 
else
   disp('exElasticBar: Check passed.'); 
end
