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

%% problem definition
problem.name = 'linearElasticBar';
problem.dimension = 1;

% element type
elementType1 = poCreateElementTypeStandardLine1d(struct(...
    'gaussOrder', 2, ...
    'youngsModulus', 1.0, ...
    'area', 1.0, ...
    'massDensity', 1.0));

problem.elementTypes = { elementType1 };

problem.elementNodeIndices = { [1 2], [2 3] };
problem.elementTopologies = [ 1 1 ];
problem.elementTypeIndices = [ 1 1 ];

% nodes
problem.nodes = [ 0, 0.5, 1.0 ];

% subelement type
subelementType1 = poCreateSubelementTypeLinearLine();

problem.subelementTypes = { subelementType1 };

problem = poCreateSubElements( problem );

% connect elements and subelements
problem = poCreateElementConnections( problem );

problem.loads = { @(x)( x ) };
problem.elementLoads = { 1, 1 };

problem.elementFoundations = { [], [] };

% damping parameter
problem.dynamics.massCoeff = 1.0;
problem.dynamics.stiffCoeff = 0.0;

%% computation of system matrices and vectors
% create system matrices
[allMe,allCe,allKe,allFe,allLe] = goCreateDynamicElementMatrices(problem);

% assemble
M = goAssembleMatrix(allMe, allLe);
C = goAssembleMatrix(allCe, allLe);
K = goAssembleMatrix(allKe, allLe);
F = goAssembleVector(allFe, allLe);

% helper functions
clampLeftSide_Matrix = @(Matrix) Matrix(2:end,2:end);
clampLeftSide_Vector = @(Vector) Vector(2:end);

% apply boundary condition
M = clampLeftSide_Matrix(M);
C = clampLeftSide_Matrix(C);
K = clampLeftSide_Matrix(K);
F = clampLeftSide_Vector(F);

