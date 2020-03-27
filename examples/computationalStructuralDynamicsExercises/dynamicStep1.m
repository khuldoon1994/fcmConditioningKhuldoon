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

%% clear variables, close figures
clear all;
close all;
clc;
warning('off', 'MATLAB:nearlySingularMatrix'); % get with [a, MSGID] = lastwarn();

%% problem definition
problem.name = 'dynamicBar1D';
problem.dimension = 1;

% dynamic element types
problem.elementTypes = { poCreateElementTypeDynamicLine1d(struct(...
    'gaussOrder', 2, ...
    'youngsModulus', 1.0, ...
    'area', 1.0, ...
    'massDensity', 1.0, ...
    'dampingCoefficient', 0.0)) };

problem.nodes = [ 0, 0.5, 1.0 ];

problem.elementNodeIndices = { [1 2], [2 3] };
problem.elementTopologies = [ 1 1 ];
problem.elementTypeIndices = [ 1 1 ];

problem = poCreateSubElements( problem );
problem = poCreateElementConnections( problem );

problem.subelementTypes = { poCreateSubelementTypeLegendreLine(struct('order', 1)) };
problem.loads = { @(x) 1.0 };
problem.penalties = { [0, 1e60] };
problem.elementLoads = { 1, 1 };
problem.elementPenalties = { [], [] };
problem.elementFoundations = { [], [] };

problem.nodeLoads = { [],[],[] };
problem.nodePenalties = { 1,[],[] };


%% dynamic analysis

% create system matrices
[ allMe, allDe, allKe, allFe, allLe ] = goCreateDynamicElementMatrices( problem );

% assemble
M = goAssembleMatrix(allMe, allLe);
D = goAssembleMatrix(allDe, allLe);
K = goAssembleMatrix(allKe, allLe);
F = goAssembleVector(allFe, allLe);



% % anstatt
%         % add penalty constraints to effective stiffness matrix
%         [ Kp, Fp ] = goCreateAndAssemblePenaltyMatrices(problem);
% %lieber
%         M = applyStrongBCtoMatrix( problem, M );
%         D = applyStrongBCtoMatrix( problem, D );
%         K = applyStrongBCtoMatrix( problem, K );
%         F = applyStrongBCtoVector( problem, F );

