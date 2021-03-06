% In SiHoFemLab, the problem definition is stored in a structure.
% In this script, the following problem will be defined:
%
%                        f(x)
%   /|---> ---> ---> ---> ---> ---> ---> --->
%   /|======================================= --> F
%   /|          rho,E,A,L
%
% A bar, characterized by its density rho, Youngs modulus E, area A and
% length L is loaded by a distributed force (one-dimensional "body-force")
% and a nodal load F.
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
p = 1;

% loads
f = @(x,t) x/L;
F0 = @(t) 0;

% damping parameter
problem.dynamics.massCoeff = 1.0;
problem.dynamics.stiffCoeff = 0.0;

% dynamic element types
problem.elementTypes = { poCreateElementTypeStandardLine1d(struct(...
    'gaussOrder', p+1, ...
    'youngsModulus', E, ...
    'area', A, ...
    'massDensity', rho)) };

problem.nodes = [ 0, 0.5*L, L ];

problem.elementNodeIndices = { [1 2], [2 3] };
problem.elementTopologies = [ 1 1 ];
problem.elementTypeIndices = [ 1 1 ];

problem = poCreateSubElements( problem );
problem = poCreateElementConnections( problem );

problem.subelementTypes = { poCreateSubelementTypeLegendreLine(struct('order', p)) };
problem.loads = { f, F0 };
problem.penalties = { [0, 1e60] };

problem.elementLoads = { 1, 1 };
problem.elementPenalties = { [], [] };
problem.elementFoundations = { [], [] };

problem.nodeLoads = { [],[],2 };
problem.nodePenalties = { 1,[],[] };

% time integration parameters
problem.dynamics.timeIntegration = 'Central Difference';
problem.dynamics.time = 0;
problem.dynamics.tStart = 0;
problem.dynamics.tStop = 10;
problem.dynamics.nTimeSteps = 401;

% initialize dynamic problem
problem = poInitializeDynamicProblem(problem);


%% dynamic analysis
% instead of typing ...
displacementAtLastNode = zeros(problem.dynamics.nTimeSteps, 1);
% better type this ...
solutionPointer = {{'displacement', [3]}};


% set initial displacement and velocity
[ nTotalDof ] = goNumberOfDof(problem);
U0Dynamic = zeros(nTotalDof, 1);
V0Dynamic = zeros(nTotalDof, 1);

% the whole dynamic analysis happens in this one function
[ solutionQuantities ] = goSolveLinearDynamics(problem, solutionPointer, U0Dynamic, V0Dynamic);
% we have an additional input called solutionPointer
% solutionPointer 'tells' our function in which outputs we are interested


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
