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

%% clear variables, close figures
clear all;
close all;
clc;
warning('off', 'MATLAB:nearlySingularMatrix'); % get with [a, MSGID] = lastwarn();

%% problem definition
problem.name = 'dynamicBar1D';
problem.dimension = 1;

% parameter
rho = 1.0;
E = 1.0;
A = 1.0;
L = 1.0;
f = @(x)( x/L );
p = 1;

% damping parameter
problem.dynamics.massCoeff = 1.0;
problem.dynamics.stiffCoeff = 0.0;

% dynamic element types
problem.elementTypes = { poCreateElementTypeDynamicLine1d(struct(...
    'gaussOrder', p+1, ...
    'youngsModulus', E, ...
    'area', A, ...
    'massDensity', rho)) };

problem.nodes = [ 0, 0.5, 1.0 ];

problem.elementNodeIndices = { [1 2], [2 3] };
problem.elementTopologies = [ 1 1 ];
problem.elementTypeIndices = [ 1 1 ];

problem = poCreateSubElements( problem );
problem = poCreateElementConnections( problem );

problem.subelementTypes = { poCreateSubelementTypeLegendreLine(struct('order', p)) };
problem.loads = { f };
% problem.penalties = { [0, 1e60] };
problem.elementLoads = { 1, 1 };
% problem.elementPenalties = { [], [] };
problem.elementFoundations = { [], [] };

problem.nodeLoads = { [],[],[] };
% problem.nodePenalties = { 1,[],[] };


%% dynamic analysis

% initialize dynamic problem /////////////////////// delete /////////////
% problem = poInitializeDynamicProblem(problem);
% nE = 11;
% problem = poCreateDynamicBarProblem(E, A, rho, 0.0, L, p, nE, f, 0, 10, 1);

% create system matrices
[ allMe, allDe, allKe, allFe, allLe ] = goCreateDynamicElementMatrices( problem );

% assemble
M = goAssembleMatrix(allMe, allLe);
D = goAssembleMatrix(allDe, allLe);
K = goAssembleMatrix(allKe, allLe);
F = goAssembleVector(allFe, allLe);

% helper functions
clampLeftSide_Matrix = @(Matrix) Matrix(2:end,2:end);
clampLeftSide_Vector = @(Vector) Vector(2:end);

% apply boundary condition
M = clampLeftSide_Matrix(M);
D = clampLeftSide_Matrix(D);
K = clampLeftSide_Matrix(K);
F = clampLeftSide_Vector(F);

