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
p = 5;

% dynamic parameters
rho = 1.0;              % mass density
alpha = 1.0;            % damping coefficient
kappa = rho * alpha;

% create dynamic problem structure
tStart = 0;
tStop = 10;
nTimeSteps = 401;
nElements = 2;

problem = poCreateDynamicBarProblem(E, A, rho, kappa, L, p, nElements, f, tStart, tStop, nTimeSteps);

% initialize dynamic problem
problem = poInitializeDynamicProblem(problem);


%% dynamic analysis
solutionPointer = {{'displacement', [3]}};


% set initial displacement and velocity
[ nTotalDof ] = goNumberOfDof(problem);
U0Dynamic = zeros(nTotalDof, 1);
V0Dynamic = zeros(nTotalDof, 1);

% the whole dynamic analysis happens in this one function
[ solutionQuantities ] = goSolveLinearDynamics(problem, solutionPointer, U0Dynamic, V0Dynamic);


% after the analysis specific quantities can be extracted from the solution
displacementAtLastNode = solutionQuantities{1};

% check for stability
poCheckDynamicStabilityCDM(problem);


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
