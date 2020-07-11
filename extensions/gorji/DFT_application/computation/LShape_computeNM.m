clear all
close all
clc


% load data
load('setup/LShape_data.mat');
load('setup/LShape_data_dynamic.mat');

% setup force
F = @(t) F0*f(t);

% time integration parameters
problem.dynamics.timeIntegration = 'Newmark Integration';
problem.dynamics.time = 0;
problem.dynamics.tStart = 0;
problem.dynamics.tStop = T;
problem.dynamics.nTimeSteps = N + 1;

% sampling time
% deltaT = T/N;
deltaT = goGetSamplingTime(problem);


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
indexQ = [37:38];

% initialize dynamic problem
problem = poInitializeDynamicProblem(problem);

uQx_NM = zeros(1, N);
uQy_NM = zeros(1, N);
uNM = zeros(nDof, N);


% set initial displacement and velocity
U0Dynamic = zeros(nDof, 1);
V0Dynamic = zeros(nDof, 1);

% compute initial acceleration
initF = F(0);
[ A0Dynamic ] = goComputeInitialAcceleration(problem, M, D, K, initF, U0Dynamic, V0Dynamic);

% initialize values
[ UDynamic, VDynamic, ADynamic ] = newmarkInitialize(problem, U0Dynamic, V0Dynamic, A0Dynamic);

% create effective system matrices
[ KEff ] = newmarkEffectiveSystemStiffnessMatrix(problem, M, D, K);
% ... and add penalty constraints
KEff = KEff + Kp;

for timeStep = 1 : N
    
    % extract necessary quantities from solution
    uQx_NM(timeStep) = UDynamic(indexQ(1));
    uQy_NM(timeStep) = UDynamic(indexQ(2));
    uNM(:,timeStep) = UDynamic;
    
    % calculate effective force vector
    ti = timeStep*deltaT;
    actualF = F(ti);
    [ FEff ] = newmarkEffectiveSystemForceVector(problem, M, D, K, actualF, UDynamic, VDynamic, ADynamic);
    % ... and add penalty constraints
    FEff = FEff + Fp;
    
    % solve linear system of equations (UNewDynamic = KEff \ FEff)
    UNewDynamic = moSolveSparseSystem( KEff, FEff );
    
    % calculate velocities and accelerations
    [ VNewDynamic, ANewDynamic ] = newmarkVelocityAcceleration(problem, UNewDynamic, UDynamic, VDynamic, ADynamic);
    
    % update kinematic quantities
    [ UDynamic, VDynamic, ADynamic ] = newmarkUpdateKinematics(UNewDynamic, VNewDynamic, ANewDynamic);
    
end

% disassemble
[ allUe ] = goDisassembleVector( UNewDynamic, allLe );

timeVector = goGetTimeVector(problem);
tNM = timeVector(1:N);



%% save results
save('computation/LShape_results_NM.mat', 'uQx_NM', 'uQy_NM', 'uNM', 'tNM');