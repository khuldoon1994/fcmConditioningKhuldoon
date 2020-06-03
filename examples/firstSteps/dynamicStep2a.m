% The elastodynamic problem will be solved using the
% Central Difference Method

% time integration parameters
problem.dynamics.timeIntegration = 'Central Difference';
problem.dynamics.time = 0;
problem.dynamics.tStart = 0;
problem.dynamics.tStop = 10;
problem.dynamics.nTimeSteps = 401;

% initialize dynamic problem
problem = poInitializeDynamicProblem(problem);


%% dynamic analysis
displacementAtLastNode = zeros(problem.dynamics.nTimeSteps, 1);
indexLastNode = 3;

% number of degrees of freedom
[ nTotalDof ] = goNumberOfDof(problem);
nBoundaryDof = 1;
nDof = nTotalDof - nBoundaryDof;
indexLastNode = indexLastNode - nBoundaryDof;

% set initial displacement and velocity
U0Dynamic = zeros(nDof, 1);
V0Dynamic = zeros(nDof, 1);

% compute initial acceleration
[ A0Dynamic ] = goComputeInitialAcceleration(problem, M, C, K, F, U0Dynamic, V0Dynamic);

% initialize values
[ UOldDynamic, UDynamic ] = cdmInitialize(problem, U0Dynamic, V0Dynamic, A0Dynamic);

% create effective system matrices
[ KEff ] = cdmEffectiveSystemStiffnessMatrix(problem, M, C, K);

for timeStep = 1 : problem.dynamics.nTimeSteps
    
    % extract necessary quantities from solution
    displacementAtLastNode(timeStep) = UDynamic(indexLastNode);
    
    % calculate effective force vector
    [ FEff ] = cdmEffectiveSystemForceVector(problem, M, C, K, F, UDynamic, UOldDynamic);
    
    % solve linear system of equations (UNewDynamic = KEff \ FEff)
    UNewDynamic = moSolveSparseSystem( KEff, FEff );
    
    % calculate velocities and accelerations
    [ VDynamic, ADynamic ] = cdmVelocityAcceleration(problem, UNewDynamic, UDynamic, UOldDynamic);
    
    % update kinematic quantities
    [ UDynamic, UOldDynamic ] = cdmUpdateKinematics(UNewDynamic, UDynamic);
    
end

% helper functions
unclampLeftSide_Matrix = @(Matrix) blkdiag(0, Matrix);
unclampLeftSide_Vector = @(Vector) [0; Vector];

% displacement at last time step
U =  unclampLeftSide_Vector(UDynamic);

% disassemble
[ allUe ] = goDisassembleVector( U, allLe );

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

title([problem.dynamics.timeIntegration, ' Method']);
xlabel('Time [sec]');
ylabel('normalized Displacement [-]');
