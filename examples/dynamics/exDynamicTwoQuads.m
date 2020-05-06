% As in step 1, a problem structure will be set up in this step. This time,
% the problem consists of ractangle, which is clamped at one end and loaded
% by a surface traction on the other end. The rectangle is 1 by 1 meters
% and should behave according plane strain physics with a Youngs modulus of
% E=1, Poisson ration nu=0.3.
%
%      _____________________
%    /|                     |--->
%    /|                     |--->
%    /|                     |--->   traction
%    /|                     |---> 
%    /|_____________________|--->
%
%    material parameter: rho, E, nu

%% clear variables, close figures
clear all;
close all;
clc;
warning('off', 'MATLAB:nearlySingularMatrix'); % get with [a, MSGID] = lastwarn();

%% problem definition
problem.name = 'dynamicTwoQuads2D (Central Difference Method)';
problem.dimension = 2;

% parameter
rho = 1.0;
E = 1.0;
nu = 0.3;
p = 2;
traction = 0.15;

% damping parameter
problem.dynamics.massCoeff = 1.0;
problem.dynamics.stiffCoeff = 0.0;


problem.nodes = [ 0.0, 1.0, 2.0, 0.0, 1.0, 2.0;
                  0.0, 0.0, 0.0, 1.0, 1.0, 1.0 ];

% element types
elementType1 = poCreateElementType( 'DYNAMIC_QUAD_2D', struct('gaussOrder', p+1, 'physics', 'PLANE_STRAIN', 'youngsModulus', E, 'poissonRatio', nu, 'massDensity', rho) );
elementType2 = poCreateElementType( 'DYNAMIC_LINE_2D', struct('gaussOrder', p+1, 'physics', 'PLANE_STRAIN', 'youngsModulus', E, 'poissonRatio', nu, 'massDensity', rho) );
problem.elementTypes = { elementType1, elementType2 };

subelementType1 = poCreateSubelementType( 'LEGENDRE_QUAD', struct('order', p) );
subelementType2 = poCreateSubelementType( 'LEGENDRE_EDGE', struct('order', p) );
problem.subelementTypes = { subelementType1, subelementType2 };

problem.elementNodeIndices = {
    [ 1 2 4 5 ]
    [ 2 3 5 6 ]
    [ 3 6 ] 
    [ 1 4] 
};

problem.elementTopologies = [ 2 2 1 1 ];
problem.elementTypeIndices = [ 1 1 2 2 ];

problem.subelementNodeIndices = {
    [ 1 2 4 5 ]
    [ 2 3 5 6 ]
    [1 2]
    [2 3]
    [4 5]
    [5 6]
    [1 4]
    [2 5]
    [3 6]
};

problem.subelementTopologies = [ 2 2 1 1 1 1 1 1 1 ];
problem.subelementTypeIndices = [ 1 1 2 2 2 2 2 2 2 ];

problem = poCreateElementConnections( problem );

problem.loads = { [ traction; 0.0 ] };
problem.penalties = { [0, 1e60; 0, 1e60] };

problem.elementLoads = { [] [] 1 [] };
problem.elementPenalties = { [] [] [] 1 };
problem.elementFoundations = { [] [] [] [] };
problem.nodeLoads = { [],[],[],[],[],[] };
problem.nodePenalties = { 1,[],[],1,[],[] };
problem.nodeFoundations = { [],[],[],[],[],[] };

% time integration parameters
problem.dynamics.timeIntegration = 'Newmark Integration';
problem.dynamics.tStart = 0;
problem.dynamics.tStop = 10;
problem.dynamics.nTimeSteps = 201;

% initialize dynamic problem
problem = poInitializeDynamicProblem(problem);


%% static analysis
[ allMe, allDe, allKe, allFe, allLe ] = goCreateDynamicElementMatrices( problem );
[ K, F ] = goAssembleSystem(allKe, allFe, allLe);

% add penalty constraints
[ Kp, Fp ] = goCreateAndAssemblePenaltyMatrices(problem);
K = K + Kp;
F = F + Fp;

uStatic = K \ F;

[ allUeStatic ] = goDisassembleVector( uStatic, allLe );


%% dynamic analysis
% Quad element:
%           /4 ---- 5 ---- 6 -->
%           /|      |      | -->
%           /|      |      | -->
%           /1 ---- 2 ---- 3 -->
%
% displacementAtSecondNodeX = Ux(node 2)
% displacementAtSecondNodeY = Uy(node 2)
% displacementAtThirdNodeX = Ux(node 3)
% displacementAtThirdNodeY = Uy(node 3)
%
% Symmetry:
%                 Ux(node 2) = Ux(node 5)
%                 Uy(node 2) = -Uy(node 5)
%                 Ux(node 3) = Ux(node 6)
%                 Uy(node 3) = -Uy(node 6)
%
% Clamped at left edge:
%                 Ux(node 1) = 0 = Ux(node 4)
%                 Uy(node 1) = 0 = Uy(node 4)

displacementAtSecondNodeX = zeros(problem.dynamics.nTimeSteps, 1);
displacementAtSecondNodeY = zeros(problem.dynamics.nTimeSteps, 1);
displacementAtThirdNodeX = zeros(problem.dynamics.nTimeSteps, 1);
displacementAtThirdNodeY = zeros(problem.dynamics.nTimeSteps, 1);

solutionPointer = {{'displacement', [3:4]}, ...
                   {'displacement', [5:6]}, ...
                   {'displacement', 'all'}};


[ nTotalDof ] = goNumberOfDof(problem);
U0Dynamic = zeros(nTotalDof, 1);
V0Dynamic = zeros(nTotalDof, 1);

% main dynamic function
[ solutionQuantities ] = goSolveLinearDynamics(problem, solutionPointer, U0Dynamic, V0Dynamic);

% post processing
displacementAtSecondNodeX = solutionQuantities{1}(1,:);
displacementAtSecondNodeY = solutionQuantities{1}(2,:);
displacementAtThirdNodeX = solutionQuantities{2}(1,:);
displacementAtThirdNodeY = solutionQuantities{2}(2,:);
allDisplacements = solutionQuantities{3};

% disassemble
allUeDynamic = goDisassembleDynamicVector(problem, allDisplacements, allLe);


%% post processing
timeVector = goGetTimeVector(problem);

% plotting the displacements of node 2 over time
figure(1);
hold on;
grid on;
plot(timeVector, displacementAtSecondNodeX, 'LineWidth', 1.6);
plot(timeVector, displacementAtSecondNodeY, 'LineWidth', 1.6);
plot(timeVector, displacementAtThirdNodeX, '--', 'LineWidth', 1.6);
plot(timeVector, displacementAtThirdNodeY, '--','LineWidth', 1.6);

title([problem.dynamics.timeIntegration, ' Method: u(t, x, y)']);
xlabel('Time [sec]');
ylabel('Displacements [meters]');
legend('u_{2,x}(t)', ...
       'u_{2,y}(t)', ...
       'u_{3,x}(t)', ...
       'u_{3,y}(t)', ...
       'Location', 'NorthWest');


% post processing
figure(2);
postGridCells = goCreatePostGrid( problem, 5 );
goPlotPostGridSolution( problem, allUeStatic, postGridCells, @eoEvaluateSolution, @eoEvaluateSolution, 2);
axis equal;
title(['Displacement solution (p = ', num2str(p), ')']);


%% post processing (animation)
pause();

% Animation
figure(3);
postGridCells = goCreatePostGrid( problem, 5 );
goPlotAnimatedPostGridSolution( problem, allUeDynamic, postGridCells, @eoEvaluateSolution, @eoEvaluateSolution, 3);

