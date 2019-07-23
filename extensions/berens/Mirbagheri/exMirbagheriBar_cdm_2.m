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
%
% This elastodynamic problem will be analyzed using cdm_2

%% clear variables, close figures
% clear all;
% close all;
% clc;
warning('off', 'MATLAB:nearlySingularMatrix'); % get with [a, MSGID] = lastwarn();

%% problem definition
problem.name = 'dynamicBar1D (Central Difference Method)';
problem.dimension = 1;

% volume load
f = @(x) 0;

% static parameters
E = 70e9;                  %(initial: 70e9)  
A = 0.0006;                %(initial: 0.0006)  
L = 20.0;                  %(initial: 20.0)       

% dynamic parameters from paper 
rho = 2700;                % mass density (initial: 2700) 
alpha = 0.0;               % damping coefficient  (initial: 0.0)
kappa = rho * alpha;

% spatial discetization
p = 3;       
n = 350;       % initial value = 100       

% temporal discretization
tStart = 0;
tStop = 0.004;
nTimeSteps = 800;    

% create problem
problem = poCreateDynamicBarProblem(E, A, rho, kappa, L, p, n, f, tStart, tStop, nTimeSteps);

% initialize dynamic problem
problem = poInitializeDynamicProblem(problem);


%% dynamic analysis
% create system matrices
[ allMe, allDe, allKe, allFe, allLe ] = goCreateDynamicElementMatrices( problem );

% assemble
M = goAssembleMatrix(allMe, allLe);
D = goAssembleMatrix(allDe, allLe);
K = goAssembleMatrix(allKe, allLe);
F = goAssembleVector(allFe, allLe);

% set initial displacement and velocity --> changed to U0, V0 
[ nTotalDof ] = goNumberOfDof(problem);
U0Dynamic = zeros(nTotalDof, 1);
V0Dynamic = zeros(nTotalDof, 1);

% compute initial acceleration --> changed with 0-ending 
[ A0Dynamic ] = goComputeInitialAcceleration(problem, M, D, K, F, U0Dynamic, V0Dynamic);

% initialize values --> changed! new function  
[ UOldDynamic, UDynamic, VDynamic, ADynamic ] = cdmInitialize_2(problem, U0Dynamic, V0Dynamic, A0Dynamic);

% create effective system matrices --> changed! new function
[ KEff ] = cdmEffectiveSystemStiffnessMatrix_2(problem, M, D, K);

% post processing stuff
indexOfLastNode = n+1;
displacementAtLastNode = zeros(problem.dynamics.nTimeSteps, 1);
velocityAtLastNode = zeros(problem.dynamics.nTimeSteps, 1);
% displacementAtAllNodes = zeros(indexOfLastNode,problem.dynamics.nTimeSteps);
% velocityAtAllNodes = zeros(indexOfLastNode,problem.dynamics.nTimeSteps);

% time loop
for timeStep = 1 : problem.dynamics.nTimeSteps
    
    disp(['time step ', num2str(timeStep)]);
    
    % extract necessary quantities from solution
    displacementAtLastNode(timeStep) = UDynamic(indexOfLastNode);
    velocityAtLastNode(timeStep) = VDynamic(indexOfLastNode);
%     displacementAtAllNodes(:,timeStep) = UDynamic;
%     velocityAtAllNodes(:,timeStep) = VDynamic;
    
    % new -> like in exDynamicBar1_2.m 
    UNewDynamic = cdmDisplacement_2(problem, UDynamic, VDynamic, ADynamic);
    
    % calculate effective force vector
    [ FEff ] = cdmEffectiveSystemForceVector_2(problem, M, D, K, F, VDynamic, ADynamic, UNewDynamic);
    % ab Zeitschritt 100 wirkt Kraft mit 1000 N auf letzten Knoten 
    if(timeStep>100)
       FEff(indexOfLastNode) = FEff(indexOfLastNode) - 1000;
    end
    
    
    ANewDynamic = moSolveSparseSystem( KEff, FEff );
    
    VNewDynamic = cdmVelocity_2(problem, VDynamic, ADynamic, ANewDynamic);
    
        % update kinematic quantities
    [ UDynamic, UOldDynamic ] = cdmUpdateKinematics(UNewDynamic, UDynamic);
    ADynamic = ANewDynamic; 
    VDynamic = VNewDynamic; 
       
end


% eventuell braucht man das --> disassemble
[ allUe ] = goDisassembleVector( UDynamic, allLe );

%% post processing
timeVector = goGetTimeVector(problem);

% plotting displacement and velocityover time
figure(1);

subplot(1,2,1)
plot(timeVector, displacementAtLastNode, '-');
title('Displacement at last node');
xlabel('Time [s]');
ylabel('Displacement [m]');

subplot(1,2,2)
plot(timeVector, velocityAtLastNode, '-');
title('Velocity at last node');
xlabel('Time [s]');
ylabel('Velcoity [m/s]');


% % show displacement/velocity movie
% figure(2);
% displacementPlot = plot(problem.nodes,displacementAtAllNodes(:,1));
% hold on
% velocityPlot = plot(problem.nodes,velocityAtAllNodes(:,1));
% axis ([0,L,min(min(displacementAtAllNodes)), max(max(displacementAtAllNodes))]);
% title('Dynamic solution');
% xlabel('Axial coordinate [m]');
% ylabel('Current solution');
% legend('Displacement', 'Velocity');
% for i=1:nTimeSteps
%     set(displacementPlot,'XData',problem.nodes,'YData',displacementAtAllNodes(:,i));
%     set(velocityPlot,'XData',problem.nodes,'YData',0.01*velocityAtAllNodes(:,i));
%     drawnow;
%     pause(0.001)
% end
% 
% 
% %show displacement movie
% figure(3);
% zeroVector = 0*problem.nodes;
% displacementPlot = plot(problem.nodes,zeroVector,'.');
% axis ([0,L*1.2,-0.1,0.1]);
% title('Dynamic solution');
% xlabel('Axial coordinate [m]');
% for i=1:nTimeSteps
%     set(displacementPlot,'XData',problem.nodes'+10000*displacementAtAllNodes(:,i),'YData',zeroVector);
%     drawnow;
%     pause(0.001)
% end

