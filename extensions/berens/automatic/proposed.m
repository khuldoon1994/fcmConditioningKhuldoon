function proposed(f, E, A, L, rho, alpha, kappa, p, n, tStart, tStop, nTimeSteps, p_nb, eta, opt )

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

%% compute initial acceleration
[ A0Dynamic ] = goComputeInitialAcceleration(problem, M, D, K, F, U0Dynamic, V0Dynamic);

% initialize values 
[ UDynamic, VDynamic, ADynamic ] = cdmInitialize(problem, U0Dynamic, V0Dynamic, A0Dynamic);

% create effective system matrices = constant and equal for both subtimesteps  
[ KEff ] = nbEffectiveSystemStiffnessMatrix(problem, M); 

%% post processing stuff
indexOfLastNode = n+1;
displacementAtLastNode = zeros(problem.dynamics.nTimeSteps, 1);
velocityAtLastNode = zeros(problem.dynamics.nTimeSteps, 1);

forcevector = zeros(problem.dynamics.nTimeSteps,1);

% time loop
for timeStep = 1 : problem.dynamics.nTimeSteps
    
    % disp(['time step ', num2str(timeStep)]);
    
    % extract necessary quantities from solution
    displacementAtLastNode(timeStep) = UDynamic(indexOfLastNode);
    velocityAtLastNode(timeStep) = VDynamic(indexOfLastNode);
    
    
    %% first subtimestep 
    
    % UNewDynamic_1 
    UNewDynamic_1 = pmDisplacement_1(problem, UDynamic, VDynamic, ADynamic, p_nb, eta);
    
    % calculate effective force vector
    T = 2; 
    omega = 2*pi/T; 
    delta_t = (tStop-tStart)/nTimeSteps; 
    % force =  0.5*(1-cos(omega*timeStep*delta_t));
    force_1 =  0.5*(1-cos(omega*((timeStep-1)*delta_t+p_nb*delta_t)));
    % forcevector(timeStep,1) = force;
    
    [ FEff_1 ] = nbEffectiveSystemForceVector_1(problem, D, K, F, VDynamic, ADynamic, UNewDynamic_1, p_nb);
    FEff_1(indexOfLastNode) = FEff_1(indexOfLastNode) + force_1;  
    
    ANewDynamic_1 = moSolveSparseSystem( KEff, FEff_1 );
    VNewDynamic_1 = nbVelocity_1(problem, VDynamic, ADynamic, ANewDynamic_1, p_nb);
    
    %% second subtimestep 
    
    % UNewDynamic_2 
    UNewDynamic_2 = pmDisplacement_2(problem, UNewDynamic_1, VNewDynamic_1, ANewDynamic_1, p_nb, eta);
    
    % calculate effective force vector
    force_2 =  0.5*(1-cos(omega*(timeStep-1)*delta_t));
    % force =  0.5*(1-cos(omega*timeStep*delta_t));
    % forcevector(timeStep,1) = force;
    
    [ FEff_2 ] = nbEffectiveSystemForceVector_2(problem, D, K, F, VNewDynamic_1, ANewDynamic_1, UNewDynamic_2, p_nb);
    FEff_2(indexOfLastNode) = FEff_2(indexOfLastNode) + force_2; 
    
     ANewDynamic_2 = moSolveSparseSystem( KEff, FEff_2 );
     VNewDynamic_2 = nbVelocity_2(problem, VNewDynamic_1, ADynamic, ANewDynamic_1, ANewDynamic_2, p_nb);
    
    % update kinematic quantities for next time step 
    UDynamic = UNewDynamic_2; 
    ADynamic = ANewDynamic_2; 
    VDynamic = VNewDynamic_2; 
       
end

% % eventuell braucht man das 
% [ allUe ] = goDisassembleVector( UDynamic, allLe );

%% post processing
timeVector = goGetTimeVector(problem);

% plotting displacement and velocity over time
if opt == 2       % if opt = proposed method 
 figure(1);
 sgtitle ('proposed method');
 
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
 
 
elseif opt == 3   % if opt = all methods
 % all figures in subplots    
 figure(1);
 subplot(3,2,5)
 hold on
 plot(timeVector, displacementAtLastNode, '-');
 title({'Proposed method';'Displacement at last node'});
 xlabel('Time [s]');
 ylabel('Displacement [m]');

 subplot(3,2,6)
 hold on 
 plot(timeVector, velocityAtLastNode, '-');
 title({'Proposed method';'Velocity at last node'});
 xlabel('Time [s]');
 ylabel('Velocity [m/s]');
 
 hold on 
 
 % all figures in one plot  
 figure(2)
 subplot(1,2,1)
 hold on 
 plot(timeVector, displacementAtLastNode, 'r-');
 title('Displacement at last node');
 xlabel('Time [s]');
 ylabel('Displacement [m]');

 subplot(1,2,2)
 hold on 
 plot(timeVector, velocityAtLastNode, 'r-');
 title('Velocity at last node');
 xlabel('Time [s]');
 ylabel('Velocity [m/s]');
 

 legend ('cdm method', 'nb method', 'proposed method'); 
end 

end
