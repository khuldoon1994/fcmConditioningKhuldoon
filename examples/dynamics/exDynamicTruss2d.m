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

problem.dynamics.time = 0;
problem.dynamics.tStart = 0;
problem.dynamics.tStop = 10;
problem.dynamics.nTimeSteps = 401;

% parameter
rho = 1;
m = 2.5;
E = 1;
A = 1;

% damping parameter
problem.dynamics.massCoeff = 0.0;
problem.dynamics.stiffCoeff = 0.0;

% gravity
g = 9.81;

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
                                   
% boundary conditions % TODO: make element loads work...
problem.loads = { [0; -m*g], [2; 1] };
problem.penalties = { [0, 1e60;
                       0, 1e60] };
problem.foundations = { };

% element boundary condition connections
problem.elementLoads = { [] };
problem.elementPenalties = { [] };
problem.elementFoundations = { [] };

% TODO: make nodal boundary condition work...
problem.nodeLoads = { [], [2] };
problem.nodePenalties = { [1], [] };
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
problem.solution = zeros(4,1);
[ allMe, allDe, allKe, allFe, allLe ] = goCreateDynamicElementMatrices( problem );

% assemble
M = goAssembleMatrix(allMe, allLe);
D = goAssembleMatrix(allDe, allLe);
K = goAssembleMatrix(allKe, allLe);
F = goAssembleVector(allFe, allLe);

% add nodal forces
Fn = goCreateNodalLoadVector(problem);
F = F + Fn;

% set initial displacement and velocity
[ nTotalDof ] = goNumberOfDof(problem);
U0 = zeros(4,1);
V0 = zeros(4,1);


% compute initial acceleration
[ A0 ] = goComputeInitialAcceleration(problem, M, D, K, F, U0, V0);

% initialize values
[ U, V, A ] = newmarkInitialize(problem, U0, V0, A0);

% create effective system matrices
[ KEff ] = newmarkEffectiveSystemStiffnessMatrix(problem, M, D, K);


for timeStep = 1 : problem.dynamics.nTimeSteps
    
    problem.dynamics.time = (problem.dynamics.tStop - problem.dynamics.tStart)*timeStep/problem.dynamics.nTimeSteps;
    
    % extract necessary quantities from solution
    displacementOverTime(:,timeStep) = U;
    velocityOverTime(:,timeStep) = V;

    % calculate effective force vector
    [ FEff ] = newmarkEffectiveSystemForceVector(problem, M, D, K, F, U, V, A);
    FEff = [0; 0; 0; -10000];
    
    % solve linear system of equations (UNew = KEff \ FEff)
    UNew = moSolveSparseSystem( KEff, FEff );
    %UNew(1:2) = zeros(1,2);
    problem.solution = UNew;
    
    % calculate velocities and accelerations
    [ VNew, ANew ] = newmarkVelocityAcceleration(problem, UNew, U, V, A);
    
    % update kinematic quantities
    [ U, V, A ] = newmarkUpdateKinematics(UNew, VNew, ANew);
    
end

%% TODO: Reactivate test
% %% post processing
% plot(2.5 + displacementOverTime(3,:), 1.5 + displacementOverTime(4,:))
% xlabel("x-position")
% ylabel("y-position")
% 
% %% check
% URef=[2.00499999999507537e+02 -1.93864452500081171e+0]';
% if sum(URef==U)==3
%    error('exElasticBar: Check failed!'); 
% else
%    disp('exElasticBar: Check passed.'); 
% end
