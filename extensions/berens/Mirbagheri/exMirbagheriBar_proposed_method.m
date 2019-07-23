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



% This elastodynamic problem will be analyzed using the proposed method from the Mirbagheri paper 
% the comments "changed.." are written in regard to the initial exMirbagheriBar.m 

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
p = 3;       % keine Veränderung möglich --> liegt an diesem skript
n = 350;       % initial value = 100       

% additional parameters  
p_nb = 0.54;              % time step coefficient from paper (also in NB method)
eta = 1.5;                % special for the proposed method 

% temporal discretization
tStart = 0;
tStop = 0.004;
nTimeSteps = 800;   % bei simsek: 505 = aber instabil --> 600 für tStop 0.5 % initial: 1001 

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

%% compute initial acceleration --> changed with 0-ending 
[ A0Dynamic ] = goComputeInitialAcceleration(problem, M, D, K, F, U0Dynamic, V0Dynamic);

% initialize values --> changed! new function  
[ UDynamic, VDynamic, ADynamic ] = cdmInitialize(problem, U0Dynamic, V0Dynamic, A0Dynamic);

% create effective system matrices = constant and equal for both subtimesteps   --> changed! new function
[ KEff ] = nbEffectiveSystemStiffnessMatrix(problem, M); 

%% post processing stuff
indexOfLastNode = n+1;
displacementAtLastNode = zeros(problem.dynamics.nTimeSteps, 1);
velocityAtLastNode = zeros(problem.dynamics.nTimeSteps, 1);

% % for the MidNode --> only works for p=1; 
% indexOfMidNode  = n/2 + 1;     
% displacementAtMidNode = zeros(problem.dynamics.nTimeSteps, 1);
% velocityAtMidNode = zeros(problem.dynamics.nTimeSteps, 1);

% displacementAtAllNodes = zeros(indexOfLastNode,problem.dynamics.nTimeSteps);
% velocityAtAllNodes = zeros(indexOfLastNode,problem.dynamics.nTimeSteps);

% time loop
for timeStep = 1 : problem.dynamics.nTimeSteps
    
    % disp(['time step ', num2str(timeStep)]);
    
    % extract necessary quantities from solution
    % for the LastNode 
    displacementAtLastNode(timeStep) = UDynamic(indexOfLastNode);
    velocityAtLastNode(timeStep) = VDynamic(indexOfLastNode);
    
%     % for the MidNode
%     displacementAtMidNode(timeStep) = UDynamic(indexOfMidNode);
%     velocityAtMidNode(timeStep) = VDynamic(indexOfMidNode);
    
%     displacementAtAllNodes(:,timeStep) = UDynamic;
%     velocityAtAllNodes(:,timeStep) = VDynamic;
    
    %% first subtimestep 
    
    % UNewDynamic_1 
    UNewDynamic_1 = pmDisplacement_1(problem, UDynamic, VDynamic, ADynamic, p_nb, eta);
    
    % calculate effective force vector
    [ FEff_1 ] = nbEffectiveSystemForceVector_1(problem, D, K, F, VDynamic, ADynamic, UNewDynamic_1, p_nb);
    % ab Zeitschritt ... wirkt Kraft mit 1000 N auf letzten Knoten  --> changed from FEff to FEff_1  
    if(timeStep>100)    %vorher = größer 100
       FEff_1(indexOfLastNode) = FEff_1(indexOfLastNode) - 1000;
    end
    
    ANewDynamic_1 = moSolveSparseSystem( KEff, FEff_1 );
    VNewDynamic_1 = nbVelocity_1(problem, VDynamic, ADynamic, ANewDynamic_1, p_nb);
    
    %% second subtimestep 
    
    % UNewDynamic_2 
    UNewDynamic_2 = pmDisplacement_2(problem, UNewDynamic_1, VNewDynamic_1, ANewDynamic_1, p_nb, eta);
    
    % calculate effective force vector
    [ FEff_2 ] = nbEffectiveSystemForceVector_2(problem, D, K, F, VNewDynamic_1, ANewDynamic_1, UNewDynamic_2, p_nb);
    % ab Zeitschritt 100 wirkt Kraft mit 1000 N auf letzten Knoten  --> changed from FEff to FEff_1  
    if(timeStep>100)
       FEff_2(indexOfLastNode) = FEff_2(indexOfLastNode) - 1000;
    end
    
     ANewDynamic_2 = moSolveSparseSystem( KEff, FEff_2 );
     VNewDynamic_2 = nbVelocity_2(problem, VNewDynamic_1, ADynamic, ANewDynamic_1, ANewDynamic_2, p_nb);
    
    % update kinematic quantities for next time step 
    UDynamic = UNewDynamic_2; 
    ADynamic = ANewDynamic_2; 
    VDynamic = VNewDynamic_2; 
       
end

% % eventuell braucht man das --> disassemble
% [ allUe ] = goDisassembleVector( UDynamic, allLe );

%% post processing
timeVector = goGetTimeVector(problem);

% plotting displacement and velocityover time
figure(1);

% new plots --> MidNode
% subplot(1,2,1)
% plot(timeVector, displacementAtMidNode, '-');
% title('Displacement at mid node');
% xlabel('Time [s]');
% ylabel('Displacement [m]');

% subplot(1,2,2)
% plot(timeVector, velocityAtMidNode, '-');
% title('Velocity at mid node');
% xlabel('Time [s]');
% ylabel('Velcoity [m/s]');


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
