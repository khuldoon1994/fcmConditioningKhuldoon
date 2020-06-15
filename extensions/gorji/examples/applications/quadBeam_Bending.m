% As in step 1, a problem structure will be set up in this step. This time,
% the problem consists of ractangle, which is clamped at one end and loaded
% by a surface traction on the other end. The rectangle is 1 by 1 meters
% and has a thickness of 1. it should behave according plane strain physics
% with a Youngs modulus of E=1, Poisson ration nu=0.3.
%
%      ____________________________________________
%    /|                                            |--->
%    /|                                            |-->
%    /|                                            |->
%    /|                                            |   traction
%    /|                                          <-|
%    /|                                         <--|
%    /|________________________________________<---|
%
%    parameter: rho, E, nu, t

%% clear variables, close figures
clear all;
close all;
clc;
warning('off', 'MATLAB:nearlySingularMatrix'); % get with [a, MSGID] = lastwarn();

%% problem definition
problem.name = 'quadBeam_bending';
problem.dimension = 2;

% geometric parameter
nE = 4;             % number of elements (in x-direction)
l = 4;              % length
h = 0.5;              % height

% parameter
rho = 1.0;
E = 1.0;
nu = 0.3;
d = 1.0;
p = 2;
% traction = @(y) 0.15;
traction = @(y) 0.05*y/h;

% damping parameter
problem.dynamics.massCoeff = 1.0;
problem.dynamics.stiffCoeff = 0.0;


dx = linspace(0,l,nE+1);
DY = h/2*ones(size(dx));
problem.nodes = [ dx, dx
                  -DY, DY ];

% element types
elementType1 = poCreateElementType( 'STANDARD_QUAD_2D', struct('gaussOrder', p+1, 'physics', 'PLANE_STRAIN', 'youngsModulus', E, 'poissonRatio', nu, 'thickness', d, 'massDensity', rho) );
elementType2 = poCreateElementType( 'STANDARD_LINE_2D', struct('gaussOrder', p+1, 'physics', 'PLANE_STRAIN', 'youngsModulus', E, 'poissonRatio', nu, 'thickness', d, 'massDensity', rho) );
problem.elementTypes = { elementType1, elementType2 };

subelementType1 = poCreateSubelementType( 'LEGENDRE_QUAD', struct('order', p) );
subelementType2 = poCreateSubelementType( 'LEGENDRE_EDGE', struct('order', p) );
problem.subelementTypes = { subelementType1, subelementType2 };






nN = nE+1;
nNodes = 2*nN;
nQuad = nE;
nEdges = 1 + 3*nE;
nT = nQuad+nEdges;

% create elements
problem.elementTopologies = zeros(1,nQuad+2);
problem.elementTypeIndices = zeros(1,nQuad+2);
problem.elementNodeIndices = cell(nQuad+2,1);
for e = 1:nQuad
    problem.elementTopologies(e) = 2;
    problem.elementTypeIndices(e) = 1;
    problem.elementNodeIndices{e} = [e, e+1, e+nN, e+1+nN];
end
for e = nQuad+1:nQuad+2
    problem.elementTopologies(e) = 1;
    problem.elementTypeIndices(e) = 2;
end
problem.elementNodeIndices{nQuad+1} = [1, nN+1];
problem.elementNodeIndices{nQuad+2} = [nN, 2*nN];


% create subelements
problem.subelementTopologies = zeros(1,nQuad+nEdges);
problem.subelementTypeIndices = zeros(1,nQuad+nEdges);
problem.subelementNodeIndices = cell(nQuad+nEdges,1);
for e = 1:nQuad
    problem.subelementTopologies(e) = 2;
    problem.subelementTypeIndices(e) = 1;
    problem.subelementNodeIndices{e} = [e, e+1, e+nN, e+1+nN];
end
for e = nQuad+1:nQuad+nEdges
    problem.subelementTopologies(e) = 1;
    problem.subelementTypeIndices(e) = 2;
end
counter = nQuad+1;
for e = 1:nE
    problem.subelementNodeIndices{counter} = [e, e+1];
    counter = counter + 1;
end
for e = 1:nE
    problem.subelementNodeIndices{counter} = nN+[e, e+1];
    counter = counter + 1;
end
for e = 1:nN
    problem.subelementNodeIndices{counter} = [e, e+nN];
    counter = counter + 1;
end

% connect elements with subelements
problem = poCreateElementConnections( problem );

% create boundary conditions
problem.loads = { @(X)[ traction(X(2)); 0.0 ] };
problem.penalties = { [0, 1e60; 0, 1e60] };
problem.foundations = { };

problem.elementLoads(1:nQuad+2) = { [] };
problem.elementLoads{nQuad+2} = 1;

problem.elementPenalties(1:nQuad+2) = { [] };
problem.elementPenalties{nQuad+1} = 1;

problem.elementFoundations(1:nQuad+2) = { [] };

problem.nodeLoads(1:nNodes) = { [] };
problem.nodePenalties(1:nNodes) = { [] };
problem.nodePenalties{1} = 1;
problem.nodePenalties{nN+1} = 1;
problem.nodeFoundations(1:nNodes) = { [] };


% time integration parameters
problem.dynamics.timeIntegration = 'Newmark Integration';
problem.dynamics.time = 0;
problem.dynamics.tStart = 0;
problem.dynamics.tStop = 10;
problem.dynamics.nTimeSteps = 101;
problem.dynamics.time = 0;


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
%           /3 ---- 4 -->
%           /|      | -->
%           /|      | -->
%           /1 ---- 2 -->
%
% displacementAtSecondNodeX = Ux(node 2)
% displacementAtSecondNodeY = Uy(node 2)
%
% Symmetry:
%                 Ux(node 2) = Ux(node 4)
%                 Uy(node 2) = -Uy(node 4)
%
% Clamped at left edge:
%                 Ux(node 1) = 0 = Ux(node 3)
%                 Uy(node 1) = 0 = Uy(node 3)

displacementAtSecondNodeX = zeros(problem.dynamics.nTimeSteps, 1);
displacementAtSecondNodeY = zeros(problem.dynamics.nTimeSteps, 1);

solutionPointer = {{'displacement', [3:4]}, ...
                   {'displacement', 'all'}};


[ nTotalDof ] = goNumberOfDof(problem);
U0Dynamic = zeros(nTotalDof, 1);
V0Dynamic = zeros(nTotalDof, 1);

% main dynamic function
[ solutionQuantities ] = goSolveLinearDynamics(problem, solutionPointer, U0Dynamic, V0Dynamic);

% post processing
displacementAtSecondNodeX = solutionQuantities{1}(1,:);
displacementAtSecondNodeY = solutionQuantities{1}(2,:);
allDisplacements = solutionQuantities{2};

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

title([problem.dynamics.timeIntegration, ' Method: u(t, x, y)']);
xlabel('Time [sec]');
ylabel('Displacements [meters]');
legend('u_{2,x}(t)', ...
       'u_{2,y}(t)', ...
       'Location', 'NorthEast');


% post processing
nCuts = 3;

figure(2);
postGridCells = goCreatePostGrid( problem, nCuts );
goPlotPostGridSolution( problem, allUeStatic, postGridCells, @eoEvaluateSolution, @eoEvaluateSolution, 2);
axis equal;
title(['Displacement solution (p = ', num2str(p), ')']);


%% post processing (animation)
disp('press enter to continue');
pause();

% Animation
figure(3);
postGridCells = goCreatePostGrid( problem, nCuts );
goPlotAnimatedPostGridSolution( problem, allUeDynamic, postGridCells, @eoEvaluateSolution, @eoEvaluateSolution, 3);

