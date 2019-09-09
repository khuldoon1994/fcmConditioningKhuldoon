function cdm( f, E, A, L, rho, alpha, kappa, p, n, tStart, tStop, nTimeSteps, opt )

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

% set initial displacement and velocity  
[ nTotalDof ] = goNumberOfDof(problem);
U0Dynamic = zeros(nTotalDof, 1);
V0Dynamic = zeros(nTotalDof, 1);

% compute initial acceleration  
[ A0Dynamic ] = goComputeInitialAcceleration(problem, M, D, K, F, U0Dynamic, V0Dynamic);

% initialize values  
[ UOldDynamic, UDynamic, VDynamic, ADynamic ] = cdmInitialize_2(problem, U0Dynamic, V0Dynamic, A0Dynamic);

% create effective system matrices
[ KEff ] = cdmEffectiveSystemStiffnessMatrix_2(problem, M, D, K);

% post processing stuff
indexOfLastNode = n+1;
displacementAtLastNode = zeros(problem.dynamics.nTimeSteps, 1);
velocityAtLastNode = zeros(problem.dynamics.nTimeSteps, 1);
% displacementAtAllNodes = zeros(indexOfLastNode,problem.dynamics.nTimeSteps);
% velocityAtAllNodes = zeros(indexOfLastNode,problem.dynamics.nTimeSteps);

forcevector = zeros(problem.dynamics.nTimeSteps,1);

%% time loop
for timeStep = 1 : problem.dynamics.nTimeSteps
    
    %disp(['time step ', num2str(timeStep)]);
    
    % extract necessary quantities from solution
    displacementAtLastNode(timeStep) = UDynamic(indexOfLastNode);
    velocityAtLastNode(timeStep) = VDynamic(indexOfLastNode);
    % displacementAtAllNodes(:,timeStep) = UDynamic;
    % velocityAtAllNodes(:,timeStep) = VDynamic;
    
    UNewDynamic = cdmDisplacement_2(problem, UDynamic, VDynamic, ADynamic);
    
    % calculate effective force vector 
    T = 2; 
    omega = 2*pi/T; 
    delta_t = (tStop-tStart)/nTimeSteps; 
    force =  0.5*(1-cos(omega*(timeStep-1)*delta_t));
    forcevector(timeStep,1) = force;
    
    [ FEff ] = cdmEffectiveSystemForceVector_2(problem, M, D, K, F, VDynamic, ADynamic, UNewDynamic);   
    FEff(indexOfLastNode) = FEff(indexOfLastNode) + force; 

% %  example with CONSTANT force acting at the beginning 
%     if (timeStep<100)
%        FEff(indexOfLastNode) = FEff(indexOfLastNode) + 1000;
%     end
%     
% forcevector(timeStep,1)=FEff(indexOfLastNode,1);  %plotting FEff 
    
    
    ANewDynamic = moSolveSparseSystem( KEff, FEff );
    
    VNewDynamic = cdmVelocity_2(problem, VDynamic, ADynamic, ANewDynamic);
    
    % update kinematic quantities
    [ UDynamic, UOldDynamic ] = cdmUpdateKinematics(UNewDynamic, UDynamic);
    ADynamic = ANewDynamic; 
    VDynamic = VNewDynamic; 
       
end

[ allUe ] = goDisassembleVector( UDynamic, allLe );   % eventuell braucht man das 

%% post processing

% % reference force plot 
% % fplot(@(x) 0.5*(1-cos((2*pi/2)*x)),[0 10],'b')

timeVector = goGetTimeVector(problem);
figure(3);
plot(timeVector, forcevector, '-');
title ('Force over time'); 

% plotting displacement and velocity over time
if opt == 0                     % if opt = cdm method  
 figure(1);
 sgtitle ('cdm method'); 
 
 subplot(1,2,1)
 hold on
 plot(timeVector, displacementAtLastNode, '-');
 title('Displacement at last node');
 xlabel('Time [s]');
 ylabel('Displacement [m]');

 subplot(1,2,2)
 hold on 
 plot(timeVector, velocityAtLastNode, '-');
 title('Velocity at last node');
 xlabel('Time [s]');
 ylabel('Velocity [m/s]');     


elseif opt == 3                 % if opt = all methods 
 % all figures in subplots   
 figure(1);

 subplot(3,2,1)
 hold on 
 plot(timeVector, displacementAtLastNode, '-');
 title({'cdm method';'Displacement at last node'});
 xlabel('Time [s]');
 ylabel('Displacement [m]');

 subplot(3,2,2)
 hold on 
 plot(timeVector, velocityAtLastNode, '-');
 title({'cdm method';'Velocity at last node'});
 xlabel('Time [s]');
 ylabel('Velocity [m/s]');
 
 
 % all figures in one plot 
 figure(2)
 subplot(1,2,1)
 hold on
 plot(timeVector, displacementAtLastNode, 'b-');
 title('Displacement at last node');
 xlabel('Time [s]');
 ylabel('Displacement [m]');
 
 subplot(1,2,2)
 hold on
 plot(timeVector, velocityAtLastNode, 'b-');
 title('Velocity at last node');
 xlabel('Time [s]');
 ylabel('Velocity [m/s]');
 
 hold on 
end 


end

