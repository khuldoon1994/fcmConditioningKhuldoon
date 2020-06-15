% In SiHoFemLab, the problem definition is stored in a structure.
% In this script, the following problem will be defined:
%
%                        f(x)
%   /|---> ---> ---> ---> ---> ---> ---> --->
%   /|=======================================
%   /|          rho,E,A,L
%
% A bar, characterized by its density rho, Youngs modulus E, area A and
% length L is loaded by a distributed force (one-dimensional "body-force").
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

% parameter
rho = 1.0;
E = 1.0;
A = 1.0;
L = 1.0;
f = @(x)( x/L );
F = 0;
p = 5;
n = 2;

% damping parameter
massCoeff = 1.0;
stiffCoeff = 0.0;

% create dynamic problem structure
tStart = 0;
tStop = 10;
nTimeSteps = 401;
nElements = 2;

problem = poCreateDynamicBarProblem(E, A, rho, L, p, n, f, F, ...
                                    tStart, tStop, nTimeSteps, ...
                                    massCoeff, stiffCoeff);

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
