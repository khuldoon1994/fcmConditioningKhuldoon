% The elastodynamic problem will be solved using the
% Newmark Integration Method

% time integration parameters
problem.dynamics.timeIntegration = 'Newmark Integration';
problem.dynamics.time = 0;
problem.dynamics.tStart = 0;
problem.dynamics.tStop = 10;
problem.dynamics.nTimeSteps = 401;

% initialize dynamic problem
problem = poInitializeDynamicProblem(problem);


%% dynamic analysis
displacementAtLastNode = zeros(problem.dynamics.nTimeSteps, 1);
velocityAtLastNode = zeros(problem.dynamics.nTimeSteps, 1);
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
[ UDynamic, VDynamic, ADynamic ] = newmarkInitialize(problem, U0Dynamic, V0Dynamic, A0Dynamic);

% create effective system matrices
[ KEff ] = newmarkEffectiveSystemStiffnessMatrix(problem, M, C, K);

for timeStep = 1 : problem.dynamics.nTimeSteps
    
    % extract necessary quantities from solution
    displacementAtLastNode(timeStep) = UDynamic(indexLastNode);
    velocityAtLastNode(timeStep) = VDynamic(indexLastNode);
    
    % calculate effective force vector
    [ FEff ] = newmarkEffectiveSystemForceVector(problem, M, C, K, F, UDynamic, VDynamic, ADynamic);
    
    % solve linear system of equations (UNewDynamic = KEff \ FEff)
    UNewDynamic = moSolveSparseSystem( KEff, FEff );
    
    % calculate velocities and accelerations
    [ VNewDynamic, ANewDynamic ] = newmarkVelocityAcceleration(problem, UNewDynamic, UDynamic, VDynamic, ADynamic);
    
    % update kinematic quantities
    [ UDynamic, VDynamic, ADynamic ] = newmarkUpdateKinematics(UNewDynamic, VNewDynamic, ANewDynamic);
    
end

% helper functions
unclampLeftSide_Matrix = @(Matrix) blkdiag(0, Matrix);
unclampLeftSide_Vector = @(Vector) [0; Vector];

% displacement at last time step
U =  unclampLeftSide_Vector(UDynamic);

% disassemble
[ allUe ] = goDisassembleVector( U, allLe );


%% post processing
timeVector = goGetTimeVector(problem);

% plotting necessary quantities over time
figure(1);
plot(timeVector, displacementAtLastNode, 'LineWidth', 1.6);
hold on;
grid on;
plot(timeVector, velocityAtLastNode, 'LineWidth', 1.6);

legend('u(t, x = L)', 'v(t, x = L)', 'Location', 'best');
title([problem.dynamics.timeIntegration, ' Method']);
xlabel('Time [sec]');
ylabel('Displacement [m], Velocity [m/s]');
