% A very simple example of an analysis script. 
% Solves the problem of an elastic bar, which is fixed on one end and
% loaded by a volume load.

%%Grafik
% (2)                     (4)                       (6)
%  :````.````.````.````.`..:/-.`.````.````.````.````:
%  :         -2-        `.``.`.`        -9-         :
%  :                  `.`  `.  `..                  :
%  :                `.`    `.    `..                :
%  :-1-          `..`      `.       ..`             :
%  :           `..`        `.         `.`-6-    -8- :
%  :         `.` -4-       `.           `.`         :
%  :       `.`             `. -5-         `.`       :
%  :     `.`               `.               `.`     :
%  :   ..`                 `.                 `..   :
%  : ..`        -3-        `.       -7-          .. :
%  :`.``.````.````.````.```.:```.````.````.````.``.`:
% (1)                      (3)                     (5)

%% clear variables, close figures
clear all; %#ok
close all;
warning('off', 'MATLAB:nearlySingularMatrix'); % get with [a, MSGID] = lastwarn();
clc;
%% problem definition
problem.name='truss2D';
problem.dimension = 2;

problem.dynamics.time = 0;
problem.dynamics.tStart = 0;
problem.dynamics.tStop = 10;
problem.dynamics.nTimeSteps = 401;

% parameter
rho = 1;
m = 2.5;
E = 1;
A = 1;

% damping parameter
problem.dynamics.massCoeff = 0.0;
problem.dynamics.stiffCoeff = 0.0;

% gravity
g = 9.81;

% subelement types
subelementType1 = poCreateSubelementType( 'LINEAR_LINE', struct() );
problem.subelementTypes = { subelementType1 };

% element types
elementType1 = poCreateElementType( 'STANDARD_TRUSS_2D', struct(...
    'youngsModulus', E, ...
    'area', A, ...
    'massDensity', rho));
problem.elementTypes = { elementType1 };

% nodes
problem.nodes = [ 0.0 0.0 1.0 1.0 2.0 2.0; 
                  0.0 1.0 0.0 1.0 0.0 1.0];
problem.nnodes= size(problem.nodes,2);

% elements or 'quadrature supports'
% problem.elementTopologies = [1];
% problem.elementTypeIndices = [1];
% problem.elementNodeIndices = { [1 2] };
problem.elementNodeIndices = { [1 2], [2 4], [1 3], [1 4], [3 4], [4 5], [3 5], [5 6], [4 6] };
problem.nelement = size(problem.elementNodeIndices,2);
problem.elementTopologies = ones(1,problem.nelement);
problem.elementTypeIndices = ones(1,problem.nelement);

% elements or 'dof supports'
% problem.subelementTopologies = [1];
% problem.subelementTypeIndices = [1];
% problem.subelementNodeIndices = { [1 2] };
problem.subelementNodeIndices =  { [1 2], [2 4], [1 3], [1 4], [3 4], [4 5], [3 5], [5 6], [4 6] };
problem.subelementTopologies = ones(1,problem.nelement);
problem.subelementTypeIndices = ones(1,problem.nelement);

% connections / transformations between elements and subelements
%problem.elementConnections = { { { 1 [1] } } };
                          
problem = poCreateElementConnections( problem );

% boundary conditions % TODO: make element loads work...
problem.loads = { [0; -m*g], [.2; .1] };
problem.penalties = { [0, 1e60;
                       0, 1e60],
                      [0, 0;
                       0, 1e60] };
problem.foundations = { };

% element boundary condition connections

% problem.elementLoads = { [] };
% problem.elementPenalties = { [] };
% problem.elementFoundations = { [] };
problem.elementLoads (1:problem.nelement)= { [] };
problem.elementPenalties (1:problem.nelement)= { [] };
problem.elementFoundations (1:problem.nelement)= { [] };

% TODO: make nodal boundary condition work...
problem.nodeLoads (1:problem.nnodes)= { [] };
problem.nodePenalties (1:problem.nnodes)= { [] };
problem.nodeFoundations (1:problem.nnodes)= { [] };

% NodeLoads
problem.nodeLoads (6)= { [2] };
problem.nodeLoads (5)= { [2] };

% Lineloads
problem.elementLoads (9)= { [] };

% Boundry Conditions
problem.nodePenalties (1)= { [1] };
problem.nodePenalties (2)= { [1] };
problem.nodePenalties (5)= { [2] };
problem.nodeFoundations (2)= { [] };

% time integration parameters
% TODO: Rename 'Newmark Integration' to 'NEWMARK', similar for CDM
problem.dynamics.timeIntegration = 'Newmark Integration';
% TODO: Rename 'No Lumping' to 'OFF'
problem.dynamics.lumping = 'No Lumping';

% initialize dynamic problem
problem = poInitializeDynamicProblem(problem);

%ProblemCheck
problem = poCheckProblem(problem);

% plot mesh and boundary conditions
% goPlotLoads(problem,1,1);
% goPlotMesh(problem,1);
% goPlotPenalties(problem,1);

%% dynamic analysis
displacementOverTime = zeros(4, problem.dynamics.nTimeSteps);
velocityOverTime = zeros(4, problem.dynamics.nTimeSteps);

% create system matrices
problem.solution = zeros(4,1);
[ allMe, allDe, allKe, allFe, allLe ] = goCreateDynamicElementMatrices( problem );

% assemble
M = goAssembleMatrix(allMe, allLe);
D = goAssembleMatrix(allDe, allLe);
K = goAssembleMatrix(allKe, allLe);
F = goAssembleVector(allFe, allLe);

% add nodal forces
Fn = goCreateNodalLoadVector(problem);
F = F + Fn;

%% Statik analysis
[ Kp, Fp ] = goCreateAndAssemblePenaltyMatrices(problem);
K = K + Kp;
F = F + Fp;
U = K\F;

problem2=problem;
problem2.nodes=reshape(U,2,[])+problem.nodes;
problem.plotData='k--';

goPlotMesh(problem,1);
goPlotMesh(problem2,1);
goPlotPenalties(problem,1);
goPlotLoads2(problem,1,1,F);
goPlotDisplacementArrows2d(problem, U, 1)

% %% Dynamik analysis
% % set initial displacement and velocity
% [ nTotalDof ] = goNumberOfDof(problem);
% U0 = zeros(4,1);
% V0 = zeros(4,1);
% 
% 
% % compute initial acceleration
% [ A0 ] = goComputeInitialAcceleration(problem, M, D, K, F, U0, V0);
% 
% % initialize values
% [ U, V, A ] = newmarkInitialize(problem, U0, V0, A0);
% 
% % create effective system matrices
% [ KEff ] = newmarkEffectiveSystemStiffnessMatrix(problem, M, D, K);
% 
% 
% for timeStep = 1 : problem.dynamics.nTimeSteps
%     
%     problem.dynamics.time = (problem.dynamics.tStop - problem.dynamics.tStart)*timeStep/problem.dynamics.nTimeSteps;
%     
%     % extract necessary quantities from solution
%     displacementOverTime(:,timeStep) = U;
%     velocityOverTime(:,timeStep) = V;
% 
%     % calculate effective force vector
%     [ FEff ] = newmarkEffectiveSystemForceVector(problem, M, D, K, F, U, V, A);
%     FEff = [0; 0; 0; -10000];
%     
%     % solve linear system of equations (UNew = KEff \ FEff)
%     UNew = moSolveSparseSystem( KEff, FEff );
%     %UNew(1:2) = zeros(1,2);
%     problem.solution = UNew;
%     
%     % calculate velocities and accelerations
%     [ VNew, ANew ] = newmarkVelocityAcceleration(problem, UNew, U, V, A);
%     
%     % update kinematic quantities
%     [ U, V, A ] = newmarkUpdateKinematics(UNew, VNew, ANew);
%     
% end
% 
% %% TODO: Reactivate test
% % %% post processing
% % plot(2.5 + displacementOverTime(3,:), 1.5 + displacementOverTime(4,:))
% % xlabel("x-position")
% % ylabel("y-position")
% % 
% % %% check
% % URef=[2.00499999999507537e+02 -1.93864452500081171e+0]';
% % if sum(URef==U)==3
% %    error('exElasticBar: Check failed!'); 
% % else
% %    disp('exElasticBar: Check passed.'); 
% % end
