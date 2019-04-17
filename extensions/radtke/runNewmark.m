function data = runNewmark(N,p,timeStepFactor)

%% problem definition
name = 'dynamicBar1D (Newmark Integration Method)';

% static parameters
E = 70e9;
A = 0.01;
L = 1.0;

% dynamic parameters
rho = 2700;              % mass density
alpha = 0.0;            % damping coefficient
kappa = rho * alpha;

tStart = 0;
tStop = 0.005;
nTimeSteps = 500 * timeStepFactor;

% force
Fhat = 0.5;
f = 25000;
omega = 2*pi*f;
n = 5;
fExt = @(t) (t<n/f).*sin(omega*t).*sin(omega*t/2/n).^2*Fhat;

%figure(2)
%t = linspace(0,2*n/f,100);
%plot(t,fExt(t));
%figure(2)

% numerial parameters
%p = 1;
%N=1000;

problem = poCreateDynamicBarProblem(E, A, rho, kappa, L, p, N, @(x) 0, tStart, tStop, nTimeSteps);
problem.dynamics.timeIntegration = 'Newmark Integration';

% initialize dynamic problem
problem = poInitializeDynamicProblem(problem);
problem.name = name;

%% dynamic analysis
displacementAtLastNode = zeros(problem.dynamics.nTimeSteps, 1);
displacementAtMiddleNode1 = zeros(problem.dynamics.nTimeSteps, 1);
displacementAtMiddleNode2 = zeros(problem.dynamics.nTimeSteps, 1);

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

% compute initial acceleration
[ A0Dynamic ] = goComputeInitialAcceleration(problem, M, D, K, F, U0Dynamic, V0Dynamic);

% initialize values
[ UDynamic, VDynamic, ADynamic ] = newmarkInitialize(problem, U0Dynamic, V0Dynamic, A0Dynamic);

% create effective system matrices
[ KEff ] = newmarkEffectiveSystemStiffnessMatrix(problem, M, D, K);

for timeStep = 1 : problem.dynamics.nTimeSteps
    
    disp(['Time step ', num2str(timeStep), '/', num2str(problem.dynamics.nTimeSteps)]);
    
    % extract necessary quantities from solution
    displacementAtLastNode(timeStep) = UDynamic(end);
    middle1 = round((size(problem.nodes,2)-1)/3) +1;
    middle2 = round((size(problem.nodes,2)-1)/3*2) +1;
    displacementAtMiddleNode1(timeStep) = UDynamic(middle1);
    displacementAtMiddleNode2(timeStep) = UDynamic(middle2);
    
    % calculate effective force vector
    [ FEff ] = newmarkEffectiveSystemForceVector(problem, M, D, K, F, UDynamic, VDynamic, ADynamic);
    
    time = problem.dynamics.tStart + timeStep * problem.dynamics.tStop / problem.dynamics.nTimeSteps;
    last = size(problem.nodes,2);
    FEff(last) = FEff(last) + fExt(time);
        
    % solve linear system of equations (UNewDynamic = KEff \ FEff)
    UNewDynamic = moSolveSparseSystem( KEff, FEff );
    
    % calculate velocities and accelerations
    [ VNewDynamic, ANewDynamic ] = newmarkVelocityAcceleration(problem, UNewDynamic, UDynamic, VDynamic, ADynamic);
    
    % update kinematic quantities
    [ UDynamic, VDynamic, ADynamic ] = newmarkUpdateKinematics(UNewDynamic, VNewDynamic, ANewDynamic);
    
end

% disassemble
[ allUe ] = goDisassembleVector( UNewDynamic, allLe );

data.dispMiddle1 = displacementAtMiddleNode1;
data.dispMiddle2 = displacementAtMiddleNode2;
data.dispLast = displacementAtLastNode;
