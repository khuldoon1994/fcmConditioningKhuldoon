clear all; %#ok
close all;

%% problem definition
name = 'dynamicBar1D (Central Difference Method)';

% static parameters
E = 70e9;
A = 0.01;
L = 1.0;

% dynamic parameters
rho = 27;              % mass density
alpha = 0.0;            % damping coefficient
kappa = rho * alpha;

soundSpeed = sqrt(E/rho);

tStart = 0;
tStop = 2e-4;
nTimeSteps = 20000;
deltaT = (tStop-tStart)/nTimeSteps;

% force
Fhat = 0.5;
f = 250000;
omega = 2*pi*f;
n = 5;
fExt = @(t) (t<n/f).*sin(omega*t).*sin(omega*t/2/n).^2;

figure(2)
t = 0:deltaT:2*n/f;
plot(t,fExt(t),'.-');
drawnow
figure(2)


% numerial parameters
p = 1;
N = 500;

problem = poCreateDynamicBarProblem(E, A, rho, kappa, L, p, N, @(x) 0, tStart, tStop, nTimeSteps);
problem.dynamics.timeIntegration = 'Central Difference';

% initialize dynamic problem
problem = poInitializeDynamicProblem(problem);
problem.name = name;

%% dynamic analysis
displacementAtLastNode = zeros(problem.dynamics.nTimeSteps, 1);
displacementAtMiddleNode = zeros(problem.dynamics.nTimeSteps, 1);

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
[ UOldDynamic, UDynamic ] = cdmInitialize(problem, U0Dynamic, V0Dynamic, A0Dynamic);

% create effective system matrices
[ KEff ] = cdmEffectiveSystemStiffnessMatrix(problem, M, D, K);
middleIndex = round((size(problem.nodes,2)-1)/2)+1;
    
for timeStep = 1 : problem.dynamics.nTimeSteps
    
    if mod(timeStep,100)==0
        disp(['Time step ', num2str(timeStep), '/', num2str(problem.dynamics.nTimeSteps)]);
    end
    
    % extract necessary quantities from solution
    displacementAtLastNode(timeStep) = UDynamic(end);
    displacementAtMiddleNode(timeStep) = UDynamic(middleIndex);
    
    % calculate effective force vector
    [ FEff ] = cdmEffectiveSystemForceVector(problem, M, D, K, F, UDynamic, UOldDynamic);
    
    time = problem.dynamics.tStart + (timeStep-1) * problem.dynamics.tStop / problem.dynamics.nTimeSteps;
    last = size(problem.nodes,2);
    FEff(last) = FEff(last) + fExt(time);
        
    % solve linear system of equations (UNewDynamic = KEff \ FEff)
    UNewDynamic = moSolveSparseSystem( KEff, FEff );
    
    % calculate velocities and accelerations
    [ VDynamic, ADynamic ] = cdmVelocityAcceleration(problem, UNewDynamic, UDynamic, UOldDynamic);
    
    % update kinematic quantities
    [ UDynamic, UOldDynamic ] = cdmUpdateKinematics(UNewDynamic, UDynamic);
    
end

% disassemble
[ allUe ] = goDisassembleVector( UDynamic, allLe );

% check for stability
poCheckDynamicStabilityCDM(problem, M, K);


%% post processing
timeVector = goGetTimeVector(problem);

% plotting necessary quantities over time
figure(1);
hold on;
plot(timeVector, displacementAtMiddleNode, 'g--', 'LineWidth', 1.6);
plot(timeVector, displacementAtLastNode, 'r--', 'LineWidth', 1.6);

travelTime = 8*(1-problem.nodes(middle2))/soundSpeed;
plot(timeVector-travelTime, displacementAtMiddleNode2, 'b-.', 'LineWidth', 1.6);

legend(['x=',num2str(problem.nodes(middle1))],['x=',num2str(problem.nodes(middle2))],['x=',num2str(problem.nodes(end))]);

%F0 = 1;
%c = sqrt(E/rho);
%ref = @(x,t) F0*L/(E*A*omega/c*L*cos(omega/c*L))*sin(omega/c*x)*cos(omega*t);
%t = linspace(0,20,1000);
%plot(t,ref(L,t));

figure(1)
