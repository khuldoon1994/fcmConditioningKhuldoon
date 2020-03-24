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

% parameters
m = 2.5;                    % mass
g = 9.81;                   % gravity

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
problem.loads = { [0; -g] };
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
problem.dynamics.lumping = 'No Lumping';

% initialize dynamic problem
problem = poInitializeDynamicProblem(problem);

% plot mesh and boundary conditions
goPlotLoads(problem,1,0.1);
%goPlotMesh(problem,1);
%goPlotPenalties(problem,1);

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
U0Dynamic = [0; 0];
V0Dynamic = [20; 30];

% compute initial acceleration
[ A0Dynamic ] = goComputeInitialAcceleration(problem, M, D, K, F, U0Dynamic, V0Dynamic);

% initialize values
[ UDynamic, VDynamic, ADynamic ] = newmarkInitialize(problem, U0Dynamic, V0Dynamic, A0Dynamic);

% create effective system matrices
[ KEff ] = newmarkEffectiveSystemStiffnessMatrix(problem, M, D, K);


for timeStep = 1 : problem.dynamics.nTimeSteps
    
    % extract necessary quantities from solution
    displacementOverTime(:,timeStep) = UDynamic;
    velocityOverTime(:,timeStep) = VDynamic;

    % calculate effective force vector
    [ FEff ] = newmarkEffectiveSystemForceVector(problem, M, D, K, F, UDynamic, VDynamic, ADynamic);
    
    % solve linear system of equations (UNewDynamic = KEff \ FEff)
    UNewDynamic = moSolveSparseSystem( KEff, FEff );
    
    % calculate velocities and accelerations
    [ VNewDynamic, ANewDynamic ] = newmarkVelocityAcceleration(problem, UNewDynamic, UDynamic, VDynamic, ADynamic);
    
    % update kinematic quantities
    [ UDynamic, VDynamic, ADynamic ] = newmarkUpdateKinematics(UNewDynamic, VNewDynamic, ANewDynamic);
    
end

%% post processing
plot(displacementOverTime(1,:), displacementOverTime(2,:))
xlabel("x-position")
ylabel("y-position")

%% check
URef=[2.00499999999507537e+02 -1.93864452500081171e+0]';
if sum(URef==UDynamic)==3
   error('exElasticBar: Check failed!'); 
else
   disp('exElasticBar: Check passed.'); 
end
