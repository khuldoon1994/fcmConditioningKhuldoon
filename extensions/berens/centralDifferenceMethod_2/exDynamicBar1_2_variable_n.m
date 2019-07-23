%% clear variables, close figures
% clear all;
% close all;
% clc;
warning('off', 'MATLAB:nearlySingularMatrix'); % get with [a, MSGID] = lastwarn();

%% problem definition
problem.name = 'dynamicBar1D (Central Difference Method)';
problem.dimension = 1;

% static parameters
E = 1.0;
A = 1.0;
L = 1.0;
f = @(x)( x/L );
p = 3;
n = 2; 

% dynamic parameters
rho = 1.0;              % mass density
alpha = 1.0;            % damping coefficient
kappa = rho * alpha;

% temporal discretization 
tStart = 0;
tStop = 10;
nTimeSteps = 401; 

% create problem
problem = poCreateDynamicBarProblem(E, A, rho, kappa, L, p, n, f, tStart, tStop, nTimeSteps);

% initialize dynamic problem
problem = poInitializeDynamicProblem(problem);


%% dynamic analysis
displacementAtLastNode = zeros(problem.dynamics.nTimeSteps, 1);

% create system matrices
[ allMe, allDe, allKe, allFe, allLe ] = goCreateDynamicElementMatrices( problem );

% assemble
M = goAssembleMatrix(allMe, allLe);
D = goAssembleMatrix(allDe, allLe);
K = goAssembleMatrix(allKe, allLe);
F = goAssembleVector(allFe, allLe);
 
% set initial displacement and velocity
[ nTotalDof ] = goNumberOfDof(problem);
U0Dynamic = zeros(nTotalDof, 1);
V0Dynamic = zeros(nTotalDof, 1);

size(U0Dynamic)
%%
% compute initial acceleration
[ A0Dynamic ] = goComputeInitialAcceleration(problem, M, D, K, F, U0Dynamic, V0Dynamic);

% initialize values
[ UOldDynamic, UDynamic, VDynamic, ADynamic ] = cdmInitialize_2(problem, U0Dynamic, V0Dynamic, A0Dynamic);

% create effective system matrices = constant 
[ KEff ] = cdmEffectiveSystemStiffnessMatrix_2(problem, M, D, K);

for timeStep = 1 : problem.dynamics.nTimeSteps
    
    % extract necessary quantities from solution  - UDynamic(3) = last node
    displacementAtLastNode(timeStep) = UDynamic(3);
    
    UNewDynamic = cdmDisplacement_2(problem, UDynamic, VDynamic, ADynamic);
    
    % calculate effective force vector
    [ FEff ] = cdmEffectiveSystemForceVector_2(problem, M, D, K, F, VDynamic, ADynamic, UNewDynamic);
    
    ANewDynamic = moSolveSparseSystem( KEff, FEff );
    
    VNewDynamic = cdmVelocity_2(problem, VDynamic, ADynamic, ANewDynamic);
    
    % update kinematic quantities
    [ UDynamic, UOldDynamic ] = cdmUpdateKinematics(UNewDynamic, UDynamic);
    ADynamic = ANewDynamic; 
    VDynamic = VNewDynamic; 
    
end

% disassemble
[ allUe ] = goDisassembleVector( UDynamic, allLe );

% check for stability
poCheckDynamicStabilityCDM(problem, M, K);


%% post processing
timeVector = goGetTimeVector(problem);

% steady state value (of displacement at last node)
uSteadyState = 16/48;

% plotting necessary quantities over time
figure(1);
plot(timeVector, displacementAtLastNode/uSteadyState, 'LineWidth', 1.6);
hold on;
grid on;
plot([timeVector(1), timeVector(end)], [1 1], 'k:', 'LineWidth', 1.6);

title([problem.dynamics.timeIntegration, ' Method: u_{norm}(t, x = L)']);
xlabel('Time [sec]');
ylabel('normalized Displacement [-]');
