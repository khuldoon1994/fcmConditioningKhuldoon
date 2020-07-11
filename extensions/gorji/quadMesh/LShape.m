%% L-Shaped Domain
%
%  !!!!!!!!!!!!!!!! load
%   ______________
%  |              |
%  |              |
%  |       _______|
%  |      |
%  |      |
%  |______|
%  ///////

%% clear variables, close figures
clear all; %#ok
close all;
warning('off', 'MATLAB:nearlySingularMatrix'); % get with [a, MSGID] = lastwarn();

% -----------------------------
simulateDynamic = true;
% simulateDynamic = false;
% -----------------------------

%% problem definition
problem.name='LShape';
problem.dimension = 2;

% polynomial degree
p=1;

% material parameter
rho = 2700;
E = 70e6;
nu = 0.3;
th = 1e-3;

% geometry parameter
L = 3.0;

% load
Fy = 500;

% element types
elementType1 = poCreateElementType( 'STANDARD_QUAD_2D', struct(...
    'gaussOrder', p+1, ...
    'physics', 'PLANE_STRAIN', ...
    'youngsModulus', E, ...
    'poissonRatio', nu, ...
    'thickness', th, ...
    'massDensity', rho) );
elementType2 = poCreateElementType( 'STANDARD_LINE_2D', struct('gaussOrder', p+1, 'physics', 'PLANE_STRAIN', 'youngsModulus', 1, 'poissonRatio', 0.3, 'thickness', 1, 'massDensity', 1.0) );
problem.elementTypes = { elementType1, elementType2 };

% mesh data
dx = L/6;
mp = ones(1,4);
mq = ones(1,7);
problem.nodes = dx * [ [0:3, 0:3, 0:3, 0:6, 0:6, 0:6, 0:6];
                       [0*mp, 1*mp, 2*mp, 3*mq, 4*mq, 5*mq, 6*mq] ];

nNodes = size(problem.nodes,2);

% low order
% nQuads = 27;
% nEdgesLoad = 6;
% nEdges = nEdgesLoad;
% 
% problem.elementTopologies = [ 2*ones(1,nQuads) 1*ones(1,nEdges) ];
% problem.elementTypeIndices = [ 1*ones(1,nQuads) 2*ones(1,nEdges) ];
% problem.elementNodeIndices = {
%     [ 1 2 5 6 ]
%     [ 1 2 5 6 ]+1
%     [ 1 2 5 6 ]+2
%     [ 1 2 5 6 ]+4+0
%     [ 1 2 5 6 ]+4+1
%     [ 1 2 5 6 ]+4+2
%     [ 1 2 5 6 ]+8+0
%     [ 1 2 5 6 ]+8+1
%     [ 1 2 5 6 ]+8+2
%     [ 13 14 20 21 ]
%     [ 13 14 20 21 ]+1
%     [ 13 14 20 21 ]+2
%     [ 13 14 20 21 ]+3
%     [ 13 14 20 21 ]+4
%     [ 13 14 20 21 ]+5
%     [ 13 14 20 21 ]+7+0
%     [ 13 14 20 21 ]+7+1
%     [ 13 14 20 21 ]+7+2
%     [ 13 14 20 21 ]+7+3
%     [ 13 14 20 21 ]+7+4
%     [ 13 14 20 21 ]+7+5
%     [ 13 14 20 21 ]+14+0
%     [ 13 14 20 21 ]+14+1
%     [ 13 14 20 21 ]+14+2
%     [ 13 14 20 21 ]+14+3
%     [ 13 14 20 21 ]+14+4
%     [ 13 14 20 21 ]+14+5
%     [ 34 35 ] % load
%     [ 34 35 ]+1
%     [ 34 35 ]+2
%     [ 34 35 ]+3
%     [ 34 35 ]+4
%     [ 34 35 ]+5
% };

% high order
nQuads = 27;
nEdgesPenalty = 3;
nEdgesLoad = 6;
nEdges = nEdgesPenalty + nEdgesLoad;

problem.elementTopologies = [ 2*ones(1,nQuads) 1*ones(1,nEdges) ];
problem.elementTypeIndices = [ 1*ones(1,nQuads) 2*ones(1,nEdges) ];
problem.elementNodeIndices = {
    [ 1 2 5 6 ]
    [ 1 2 5 6 ]+1
    [ 1 2 5 6 ]+2
    [ 1 2 5 6 ]+4+0
    [ 1 2 5 6 ]+4+1
    [ 1 2 5 6 ]+4+2
    [ 1 2 5 6 ]+8+0
    [ 1 2 5 6 ]+8+1
    [ 1 2 5 6 ]+8+2
    [ 13 14 20 21 ]
    [ 13 14 20 21 ]+1
    [ 13 14 20 21 ]+2
    [ 13 14 20 21 ]+3
    [ 13 14 20 21 ]+4
    [ 13 14 20 21 ]+5
    [ 13 14 20 21 ]+7+0
    [ 13 14 20 21 ]+7+1
    [ 13 14 20 21 ]+7+2
    [ 13 14 20 21 ]+7+3
    [ 13 14 20 21 ]+7+4
    [ 13 14 20 21 ]+7+5
    [ 13 14 20 21 ]+14+0
    [ 13 14 20 21 ]+14+1
    [ 13 14 20 21 ]+14+2
    [ 13 14 20 21 ]+14+3
    [ 13 14 20 21 ]+14+4
    [ 13 14 20 21 ]+14+5
    [ 34 35 ] % load
    [ 34 35 ]+1
    [ 34 35 ]+2
    [ 34 35 ]+3
    [ 34 35 ]+4
    [ 34 35 ]+5
    [ 1 2 ] % penalty
    [ 2 3 ]
    [ 3 4 ]
};

% this could be done automatically, e.g 
% [ problem.nodes, problem.cells ] = readMesh(adhocMeshFile.qua);    

% subelement types
% low order
subelementType1 = poCreateSubelementType( 'LINEAR_QUAD', { } );
problem.subelementTypes = { subelementType1 };


% high order
% subelementType1 = poCreateSubelementType( 'LEGENDRE_QUAD', struct('order', p) );
% subelementType2 = poCreateSubelementType( 'LEGENDRE_EDGE', struct('order', p) );
% problem.subelementTypes = { subelementType1, subelementType2 };

% subelements
% low order
problem.subelementTopologies = [ 2*ones(1,nQuads) ];
problem.subelementTypeIndices = [ 1*ones(1,nQuads) ];
problem.subelementNodeIndices = {
    [ 1 2 5 6 ]
    [ 1 2 5 6 ]+1
    [ 1 2 5 6 ]+2
    [ 1 2 5 6 ]+4+0
    [ 1 2 5 6 ]+4+1
    [ 1 2 5 6 ]+4+2
    [ 1 2 5 6 ]+8+0
    [ 1 2 5 6 ]+8+1
    [ 1 2 5 6 ]+8+2
    [ 13 14 20 21 ]
    [ 13 14 20 21 ]+1
    [ 13 14 20 21 ]+2
    [ 13 14 20 21 ]+3
    [ 13 14 20 21 ]+4
    [ 13 14 20 21 ]+5
    [ 13 14 20 21 ]+7+0
    [ 13 14 20 21 ]+7+1
    [ 13 14 20 21 ]+7+2
    [ 13 14 20 21 ]+7+3
    [ 13 14 20 21 ]+7+4
    [ 13 14 20 21 ]+7+5
    [ 13 14 20 21 ]+14+0
    [ 13 14 20 21 ]+14+1
    [ 13 14 20 21 ]+14+2
    [ 13 14 20 21 ]+14+3
    [ 13 14 20 21 ]+14+4
    [ 13 14 20 21 ]+14+5
};

% high order
% nEveryEdge = 66;
% problem.subelementTopologies = [ 2*ones(1,nQuads), 1*ones(1,nEveryEdge) ];
% problem.subelementTypeIndices = [ 1*ones(1,nQuads), 2*ones(1,nEveryEdge) ];
% problem.subelementNodeIndices = {
%     [ 1 2 5 6 ]
%     [ 1 2 5 6 ]+1
%     [ 1 2 5 6 ]+2
%     [ 1 2 5 6 ]+4+0
%     [ 1 2 5 6 ]+4+1
%     [ 1 2 5 6 ]+4+2
%     [ 1 2 5 6 ]+8+0
%     [ 1 2 5 6 ]+8+1
%     [ 1 2 5 6 ]+8+2
%     [ 13 14 20 21 ]
%     [ 13 14 20 21 ]+1
%     [ 13 14 20 21 ]+2
%     [ 13 14 20 21 ]+3
%     [ 13 14 20 21 ]+4
%     [ 13 14 20 21 ]+5
%     [ 13 14 20 21 ]+7+0
%     [ 13 14 20 21 ]+7+1
%     [ 13 14 20 21 ]+7+2
%     [ 13 14 20 21 ]+7+3
%     [ 13 14 20 21 ]+7+4
%     [ 13 14 20 21 ]+7+5
%     [ 13 14 20 21 ]+14+0
%     [ 13 14 20 21 ]+14+1
%     [ 13 14 20 21 ]+14+2
%     [ 13 14 20 21 ]+14+3
%     [ 13 14 20 21 ]+14+4
%     [ 13 14 20 21 ]+14+5
%     [ 1 2 ]
%     [ 1 2 ]+1
%     [ 1 2 ]+2
%     [ 1 2 ]+4+0
%     [ 1 2 ]+4+1
%     [ 1 2 ]+4+2
%     [ 1 2 ]+8+0
%     [ 1 2 ]+8+1
%     [ 1 2 ]+8+2
%     [ 13 14 ]
%     [ 13 14 ]+1
%     [ 13 14 ]+2
%     [ 13 14 ]+3
%     [ 13 14 ]+4
%     [ 13 14 ]+5
%     [ 13 14 ]+7+0
%     [ 13 14 ]+7+1
%     [ 13 14 ]+7+2
%     [ 13 14 ]+7+3
%     [ 13 14 ]+7+4
%     [ 13 14 ]+7+5
%     [ 13 14 ]+14+0
%     [ 13 14 ]+14+1
%     [ 13 14 ]+14+2
%     [ 13 14 ]+14+3
%     [ 13 14 ]+14+4
%     [ 13 14 ]+14+5
%     [ 13 14 ]+21+0
%     [ 13 14 ]+21+1
%     [ 13 14 ]+21+2
%     [ 13 14 ]+21+3
%     [ 13 14 ]+21+4
%     [ 13 14 ]+21+5
%     [ 1 5 ]
%     [ 1 5 ]+4
%     [ 1 5 ]+8
%     [ 13 20 ]
%     [ 13 20 ]+7
%     [ 13 20 ]+14
%     [ 1 5 ]+1
%     [ 1 5 ]+4+1
%     [ 1 5 ]+8+1
%     [ 13 20 ]+1
%     [ 13 20 ]+7+1
%     [ 13 20 ]+14+1
%     [ 1 5 ]+2
%     [ 1 5 ]+4+2
%     [ 1 5 ]+8+2
%     [ 13 20 ]+2
%     [ 13 20 ]+7+2
%     [ 13 20 ]+14+2
%     [ 1 5 ]+3
%     [ 1 5 ]+4+3
%     [ 1 5 ]+8+3
%     [ 13 20 ]+3
%     [ 13 20 ]+7+3
%     [ 13 20 ]+14+3
%     [ 17 24 ]
%     [ 17 24 ]+7
%     [ 17 24 ]+14
%     [ 17 24 ]+1
%     [ 17 24 ]+7+1
%     [ 17 24 ]+14+1
%     [ 17 24 ]+2
%     [ 17 24 ]+7+2
%     [ 17 24 ]+14+2
% };

% this could be done automatically, e.g 
% problem.subelements = { problem.elements, createEdgesFromFaces(problem.elements) };    

% element cell connection
%problem.cellElementConnections = {
%    { { 1 [ 1, 0; 0, 1] } },
%    { { 1 [ 0, 1; 1, 0] } }
%};

% % high order
% problem.elementConnections = {
%      { { 1 [ 1, 0; 0, 1] }
%        { 2 [ 1, 0; 0,-1] }
%        { 3 [ 1, 0; 0, 1] }
%        { 4 [ 0, 1;-1, 0] }
%        { 5 [ 0, 1; 1, 0] } }
%      { { 4 [ 1, 0; 0,-1] } }
%      { { 1 [ 0, 1; 1, 0] }
%        { 5 [ 1, 0; 0, 1] } }      
% };
% this can be done automatically, e.g 
problem = poCreateElementConnections( problem );


% boundary conditions
problem.loads = { [ 0.0; -Fy ] };
problem.penalties = { [0, 1e15; 0, 1e15] };
problem.foundations = { }; %foundations added

problem.elementLoads = cell(1,nQuads+nEdges);
problem.elementPenalties = cell(1,nQuads+nEdges);
problem.elementFoundations = cell(1,nQuads+nEdges);
problem.nodeLoads = cell(1,nNodes);
problem.nodePenalties = cell(1,nNodes);
problem.nodeFoundations = cell(1,nNodes);

counter = nQuads;
problem.elementLoads(counter+1:counter+nEdgesLoad) = { 1 };
counter = nQuads+nEdgesLoad;
problem.elementPenalties(counter+1:counter+nEdgesPenalty) = { 1 };
problem.nodePenalties(1:nEdgesPenalty+1) = { 1 };



% check and complete problem data structure
problem = poCheckProblem(problem);

% plot mesh and boundary conditions
scaleForce = 5e-4;

goPlotMesh(problem,1);
goPlotLoads(problem,1,scaleForce);
goPlotPenalties(problem,1);
title('Problem setup');
axis equal;


%% static analysis
[ allKe, allFe, allLe ] = goCreateElementMatrices( problem );

[ K, F ] = goAssembleSystem(allKe, allFe, allLe);

U = K \ F;

[ allUe ] = goDisassembleVector( U, allLe );


% post processing
postGridCells = goCreatePostGrid( problem, 1 );
figure(2);
goPlotPostGridSolution( problem, allUe, postGridCells, @eoEvaluateSolution, @eoEvaluateSolution, 2);
axis equal;
title('Displacement solution');












%% dynamic analysis
%
%  !!!!!!!!!!!!!!!!
%   ______________
%  |              |
%  |              |
%  |       _______Q
%  |      |
%  |      |
%  |______|
%  ///////
%
% displacement = displacement at point Q
    
if(simulateDynamic)
    % damping parameter
    problem.dynamics.massCoeff = 0.1;
    problem.dynamics.stiffCoeff = 0.01;
    
    % time integration parameters
    problem.dynamics.timeIntegration = 'Newmark Integration';
    problem.dynamics.time = 0;
    problem.dynamics.tStart = 0;
    problem.dynamics.tStop = 10;
    problem.dynamics.nTimeSteps = 201;
    problem.dynamics.time = 0;
    
    % initialize dynamic problem
    problem = poInitializeDynamicProblem(problem);
    
    displacementX = zeros(problem.dynamics.nTimeSteps, 1);
    displacementY = zeros(problem.dynamics.nTimeSteps, 1);
    
    solutionPointer = {{'displacement', [37:38]}, ...
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
    
    
    % post processing
    timeVector = goGetTimeVector(problem);
    
    % plotting the displacements of node Q over time
    figure(3);
    hold on;
    grid on;
    plot(timeVector, displacementAtSecondNodeX, 'LineWidth', 1.6);
    plot(timeVector, displacementAtSecondNodeY, 'LineWidth', 1.6);
    
    title([problem.dynamics.timeIntegration, ' Method: u(t, x, y)']);
    xlabel('Time [sec]');
    ylabel('Displacements [meters]');
    legend('u_{Q,x}(t)', ...
        'u_{Q,y}(t)', ...
        'Location', 'NorthEast');
    
    
    % post processing (animation)
    disp('press enter to continue');
    pause();
    
    % Animation
    figure(4);
    postGridCells = goCreatePostGrid( problem, 0 );
    goPlotAnimatedPostGridSolution( problem, allUeDynamic, postGridCells, @eoEvaluateSolution, @eoEvaluateSolution, 4);
end
