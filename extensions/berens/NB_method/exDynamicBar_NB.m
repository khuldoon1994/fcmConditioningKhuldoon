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
% This elastodynamic problem will be analyzed using
% NB (Noh and Bathe) method from Mirbagheri paper 

%% clear variables, close figures
clear all;
close all;
clc;
warning('off', 'MATLAB:nearlySingularMatrix'); % get with [a, MSGID] = lastwarn();

%% problem definition
problem.name = 'dynamicBar1D (NB method)';
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

% special for NB method 
p_nb = 0.54;            % time step coefficient from paper 


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
problem.dynamics.timeIntegration = 'Central Difference';
problem.dynamics.lumping = 'No Lumping';
problem.dynamics.tStart = 0;
problem.dynamics.tStop = 50;         %initial value 10 
problem.dynamics.nTimeSteps = 1500;   %initial value 401

% initialize dynamic problem
problem = poInitializeDynamicProblem(problem);


%% dynamic analysis
displacementAtLastNode = zeros(problem.dynamics.nTimeSteps, 1);

% create system matrices
[ allMe, allDe, allKe, allFe, allLe ] = goCreateDynamicElementMatrices( problem );

% assemble
M = goAssembleMatrix(allMe, allLe);
D = goAssembleMatrix(allDe, allLe);
K = goAssembleMatrix(allKe, allLe);
F = goAssembleVector(allFe, allLe);

% set initial displacement and velocity
[ nTotalDof ] = goNumberOfDof(problem);
U0Dynamic = zeros(nTotalDof, 1);
V0Dynamic = zeros(nTotalDof, 1);

%%
% compute initial acceleration
[ A0Dynamic ] = goComputeInitialAcceleration(problem, M, D, K, F, U0Dynamic, V0Dynamic);

% initialize values
[ UOldDynamic, UDynamic, VDynamic, ADynamic ] = cdmInitialize(problem, U0Dynamic, V0Dynamic, A0Dynamic);

% create effective system matrices = constant and equal for both subtimesteps 
[ KEff ] = nbEffectiveSystemStiffnessMatrix(problem, M);


for timeStep = 1 : problem.dynamics.nTimeSteps
    
    % extract necessary quantities from solution  - UDynamic(3) = last node
    displacementAtLastNode(timeStep) = UDynamic(3);
    
    
    %% first subtimestep 
    
    % UNewDynamic_1 
    UNewDynamic_1 = nbDisplacement_1(problem, UDynamic, VDynamic, ADynamic, p_nb);
    
    % FEff_1 - calculate effective force vector 
    [ FEff_1 ] = nbEffectiveSystemForceVector_1(problem, D, K, F, VDynamic, ADynamic, UNewDynamic_1, p_nb);
    
    % ANewDynamic_1 
    ANewDynamic_1 = moSolveSparseSystem( KEff, FEff_1 );
    
    % VNewDynamic_1 
    VNewDynamic_1 = nbVelocity_1(problem, VDynamic, ADynamic, ANewDynamic_1, p_nb);

    %% second subtimestep 
    
    % UNewDynamic_2 
    UNewDynamic_2 = nbDisplacement_2(problem, UNewDynamic_1, VNewDynamic_1, ANewDynamic_1, p_nb);
    
    % FEff_2 
    [ FEff_2 ] = nbEffectiveSystemForceVector_2(problem, D, K, F, VNewDynamic_1, ANewDynamic_1, UNewDynamic_2, p_nb);
    
    % ANewDynamic_2 
    ANewDynamic_2 = moSolveSparseSystem( KEff, FEff_2 );
    
    % VNewDynamic_2
    VNewDynamic_2 = nbVelocity_2(problem, VNewDynamic_1, UDynamic, UNewDynamic_1,UNewDynamic_2, p_nb);
    
   
    % update kinematic quantities for next time step 
    %[ UDynamic, UOldDynamic ] = cdmUpdateKinematics(UNewDynamic_2, UDynamic);
    UDynamic = UNewDynamic_2; 
    ADynamic = ANewDynamic_2; 
    VDynamic = VNewDynamic_2 ; 
end

% disassemble
[ allUe ] = goDisassembleVector( UDynamic, allLe );

% check for stability
poCheckDynamicStabilityCDM(problem, M, K);


%% post processing
timeVector = goGetTimeVector(problem);

% steady state value (of displacement at last node)
uSteadyState = 16/48;

% plotting necessary quantities over time
figure(1);
plot(timeVector, displacementAtLastNode/uSteadyState, 'LineWidth', 1.6);
hold on;
grid on;
plot([timeVector(1), timeVector(end)], [1 1], 'k:', 'LineWidth', 1.6);

title([problem.dynamics.timeIntegration, ' Method: u_{norm}(t, x = L)']);
xlabel('Time [sec]');
ylabel('normalized Displacement [-]');
