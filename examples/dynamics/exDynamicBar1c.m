% In SiHoFemLab, the problem definition is stored in a structure.
% In this script, the following problem will be defined:
%
%                        f(x)
%   /|---> ---> ---> ---> ---> ---> ---> --->
%   /|=======================================
%   /|          E,A,rho,kappa,L
%
% A bar, characterized by its Youngs modulus E, area A,
% mass density rho, damping coefficient kappa and length L
% is loaded by a distributed force (one-dimensional "body-force").
%
% This elastodynamic problem will be analyzed using
% Central Difference Method

%% clear variables, close figures
clear all;
close all;
clc;
warning('off', 'MATLAB:nearlySingularMatrix'); % get with [a, MSGID] = lastwarn();

%% problem definition
problem.name = 'dynamicBar1D (Central Difference Method)';
problem.dimension = 1;

% static parameters
E = 1.0;
A = 1.0;
L = 1.0;
f = @(x)( x/L );

% dynamic parameters
rho = 1.0;              % mass density
alpha = 1.0;            % damping coefficient
kappa = rho * alpha;

p = 5;
n = 2;

tStart = 0;
tStop = 10;
nTimeSteps = 401;

problem = poCreateDynamicBarProblem(E, A, rho, kappa, L, p, n, f, tStart, tStop, nTimeSteps);

indexOfLastNode = n+1;


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

% compute initial acceleration
[ A0Dynamic ] = goComputeInitialAcceleration(problem, M, D, K, F, U0Dynamic, V0Dynamic);

% initialize values
[ UOldDynamic, UDynamic ] = cdmInitialize(problem, U0Dynamic, V0Dynamic, A0Dynamic);

% create effective system matrices
[ KEff ] = cdmEffectiveSystemStiffnessMatrix(problem, M, D, K);

for timeStep = 1 : problem.dynamics.nTimeSteps
    
    % extract necessary quantities from solution
    displacementAtLastNode(timeStep) = UDynamic(3);
    
    % calculate effective force vector
    [ FEff ] = cdmEffectiveSystemForceVector(problem, M, D, K, F, UDynamic, UOldDynamic);
    
    FEff(3) = FEff(3) + 1;
    
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