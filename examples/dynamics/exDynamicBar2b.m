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
% Newmark Integration Method

%% clear variables, close figures
clear all;
close all;
clc;
warning('off', 'MATLAB:nearlySingularMatrix'); % get with [a, MSGID] = lastwarn();

%% problem definition
problem.name = 'dynamicBar1D (Newmark Integration Method)';
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

% dynamic element types
problem.elementTypes = { poCreateElementTypeDynamicLine1d(struct(...
    'gaussOrder', p+1, ...
    'youngsModulus', E, ...
    'area', A, ...
    'massDensity', rho, ...
    'dampingCoefficient', kappa)) };

problem.nodes = [ 0, 0.5*L, L ];

problem.elementNodeIndices = { [1 2], [2 3] };
problem.elementTopologies = [ 1 1 ];
problem.elementTypeIndices = [ 1 1 ];

problem = poCreateSubElements( problem );
problem = poCreateElementConnections( problem );

problem.subelementTypes = { poCreateSubelementTypeLegendreLine(struct('order', p)) };
problem.loads = { f };
problem.penalties = { [0, 1e60] };
problem.elementLoads = { 1, 1 };
problem.elementPenalties = { [], [] };
problem.elementFoundations = { [], [] };

problem.nodeLoads = { [],[],[] };
problem.nodePenalties = { 1,[],[] };

% time integration parameters
problem.dynamics.timeIntegration = 'Newmark Integration';
problem.dynamics.lumping = 'No Lumping';
problem.dynamics.tStart = 0;
problem.dynamics.tStop = 10;
problem.dynamics.nTimeSteps = 401;

% initialize dynamic problem
problem = poInitializeDynamicProblem(problem);


%% dynamic analysis
% instead of typing ...
displacementAtLastNode = zeros(problem.dynamics.nTimeSteps, 1);
velocityAtLastNode = zeros(problem.dynamics.nTimeSteps, 1);
% better type this ...
solutionPointer = {{'displacement', [3]}, ...
                   {'velocity', [3]}};


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
velocityAtLastNode = solutionQuantities{2};


%% post processing
timeVector = goGetTimeVector(problem);

% plotting necessary quantities over time
figure(1);
plot(timeVector, displacementAtLastNode, 'LineWidth', 1.6);
hold on;
grid on;
plot(timeVector, velocityAtLastNode, 'LineWidth', 1.6);

legend('u(t, x = L)', 'v(t, x = L)', 'Location', 'best');
title([problem.dynamics.timeIntegration, ' Method: u(t, x = L), v(t, x = L)']);
xlabel('Time [sec]');
ylabel('Displacement [m], Velocity [m/s]');
