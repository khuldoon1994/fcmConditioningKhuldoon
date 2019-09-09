%% clear variables, close figures
% clear all;
% close all;
% clc;
warning('off', 'MATLAB:nearlySingularMatrix'); % get with [a, MSGID] = lastwarn();

%% problem definition
problem.name = 'dynamicBar1D (Central Difference Method)';
problem.dimension = 1;

% volume load
f = @(x) 0;

% static parameters
A = 0.0006;                %(initial: 0.0006)  
E = 70e9*A;                  %(initial: 70e9)  
L = 20.0;                  %(initial: 20.0)       

% dynamic parameters from paper 
rho = 2700*A;                % mass density (initial: 2700) 
alpha = 0.0;               % damping coefficient  (initial: 0.0)
kappa = rho * alpha;

% spatial discretization
p = 2;        
n = 500;

% temporal discretization
tStart = 0;
tStop = 0.008;        % paper = 0.004
deltaT = 5e-6;
nTimeSteps = tStop/deltaT;   % bei simsek: 505 = aber instabil --> 601 , paper = 800
tau = 0.0;

% create problem
problem = poCreateDynamicBarProblem(E, A, rho, kappa, L, p, n, f, tStart, tStop, nTimeSteps);

% initialize dynamic problem
problem = poInitializeDynamicProblem(problem);

%% dynamic analysis
% create system matrices
[ allMe, allDe, allKe, allFe, allLe ] = goCreateDynamicElementMatrices( problem );

% assemble
M = goAssembleMatrix(allMe, allLe);
D = goAssembleMatrix(allDe, allLe);
K = goAssembleMatrix(allKe, allLe);
F = goAssembleVector(allFe, allLe);

% set initial displacement and velocity
[ nTotalDof ] = goNumberOfDof(problem);
UDynamic = zeros(nTotalDof, 1);
VDynamic = zeros(nTotalDof, 1);

%%
% compute initial acceleration
[ ADynamic ] = goComputeInitialAcceleration(problem, M, D, K, F, UDynamic, VDynamic);

% initialize values
[ UOldDynamic, UDynamic ] = cdmInitialize(problem, UDynamic, VDynamic, ADynamic);

% create effective system matrices
[ KEff ] = cdmEffectiveSystemStiffnessMatrix(problem, M, D, K);

% post processing stuff
indexOfLastNode = n+1;
displacementAtLastNode = zeros(problem.dynamics.nTimeSteps, 1);
velocityAtLastNode = zeros(problem.dynamics.nTimeSteps, 1);

indexOfMiddleNode = n/2+1;
displacementAtMiddleNode = zeros(problem.dynamics.nTimeSteps, 1);
velocityAtMiddleNode = zeros(problem.dynamics.nTimeSteps, 1);


displacementAtAllNodes = zeros(indexOfLastNode,problem.dynamics.nTimeSteps);
% velocityAtAllNodes = zeros(indexOfLastNode,problem.dynamics.nTimeSteps);

% time loop
for timeStep = 1 : problem.dynamics.nTimeSteps
    
%   disp(['time step ', num2str(timeStep)]);
    
    % extract necessary quantities from solution
    displacementAtLastNode(timeStep) = UDynamic(indexOfLastNode);
    velocityAtLastNode(timeStep) = VDynamic(indexOfLastNode);

    displacementAtMiddleNode(timeStep) = UDynamic(indexOfMiddleNode);
    velocityAtMiddleNode(timeStep) = VDynamic(indexOfMiddleNode);

    %   displacementAtAllNodes(:,timeStep) = UDynamic(1:n+1);
%   velocityAtAllNodes(:,timeStep) = VDynamic(1+n+1);
    
    % calculate effective force vector
    [ FEff ] = cdmEffectiveSystemForceVector(problem, M, D, K, F, UDynamic, UOldDynamic);
    
    % beim Zeitschritt wirkt Kraft mit 1000 N auf letzten Knoten 
    if(timeStep*deltaT>=tau)
       FEff(indexOfLastNode) = FEff(indexOfLastNode) - 1000;
    end
    
    % solve linear system of equations
    UNewDynamic = moSolveSparseSystem( KEff, FEff );
    
    % calculate velocities and accelerations
    [ VDynamic, ADynamic ] = cdmVelocityAcceleration(problem, UNewDynamic, UDynamic, UOldDynamic);
    
    % update kinematic quantities
    [ UDynamic, UOldDynamic ] = cdmUpdateKinematics(UNewDynamic, UDynamic);
    
end

% disassemble
[ allUe ] = goDisassembleVector( UDynamic, allLe );
%% post processing
timeVector = goGetTimeVector(problem);

% plotting displacement and velocityover time
figure(1);

subplot(1,2,1)
plot(timeVector, displacementAtLastNode, '-');
title('Displacement at last node');
xlabel('Time [s]');
ylabel('Displacement [m]');

subplot(1,2,2)
plot(timeVector, velocityAtLastNode, '-');
title('Velocity at last node');
xlabel('Time [s]');
ylabel('Velcoity [m/s]');


figure(2);

subplot(1,2,1)
plot(timeVector, displacementAtMiddleNode, '-');
title('Displacement at middle node');
xlabel('Time [s]');
ylabel('Displacement [m]');

subplot(1,2,2)
plot(timeVector, velocityAtMiddleNode, '-');
title('Velocity at middle node');
xlabel('Time [s]');
ylabel('Velcoity [m/s]');
