function data = computeCDM(N,p,timeStepFactor)
 
    data=struct();

    data.N=N;
    data.p=p;
    data.timeStepFactor=timeStepFactor;

    name = 'dynamicBar1D (Central Difference Method)';

    % static parameters
    E = 70e9;
    A = 0.01;
    L = 1.0;

    % dynamic parameters
    rho = 2700;              % mass density
    alpha = 0.0;            % damping coefficient
    kappa = rho * alpha;

    macroSteps = 500;
    tStart = 0;
    tStop = 0.002;
    nTimeSteps = macroSteps*timeStepFactor;
    deltaT = (tStop-tStart)/nTimeSteps;

    N = 30*N;
    
    % force
    Fhat = 0.5;
    f = 25000;
    omega = 2*pi*f;
    n = 5;
    fExt = @(t) (t<n/f) .* sin(omega*t) .* sin(omega*t/2/n).^2 * Fhat;

    problem = poCreateDynamicBarProblem(E, A, rho, kappa, L, p, N, @(x) 0, tStart, tStop, nTimeSteps);
    problem.dynamics.timeIntegration = 'Central Difference';

    % initialize dynamic problem
    problem = poInitializeDynamicProblem(problem);
    problem.name = name;

    %% dynamic analysis
    data.displacementAtLastNode = zeros(macroSteps, 1);
    data.displacementAtMiddleNode1 = zeros(macroSteps, 1);
    data.displacementAtMiddleNode2 = zeros(macroSteps, 1);

    middle1 = round((size(problem.nodes,2)-1)/3) +1;
    middle2 = round((size(problem.nodes,2)-1)/3*2) +1;

    data.xMiddle1 = problem.nodes(middle1);
    data.xMiddle2 = problem.nodes(middle2);
    data.xLast = problem.nodes(end);
    data.nTimeSteps = nTimeSteps;
    data.deltaT = deltaT;
    data.N = N;
    data.p = p;
    
    % create system matrices
    [ allMe, allDe, allKe, allFe, allLe ] = goCreateDynamicElementMatrices( problem );

    % assemble
    M = goAssembleMatrix(allMe, allLe);
    D = goAssembleMatrix(allDe, allLe);
    K = goAssembleMatrix(allKe, allLe);
    F = goAssembleVector(allFe, allLe);

    % set initial displacement and velocity
    [ nTotalDof ] = goNumberOfDof(problem);
    data.dof = nTotalDof;
    U0Dynamic = zeros(nTotalDof, 1);
    V0Dynamic = zeros(nTotalDof, 1);

    % compute initial acceleration
    [ A0Dynamic ] = goComputeInitialAcceleration(problem, M, D, K, F, U0Dynamic, V0Dynamic);

    % initialize values
    [ UOldDynamic, UDynamic ] = cdmInitialize(problem, U0Dynamic, V0Dynamic, A0Dynamic);

    % create effective system matrices
    [ KEff ] = cdmEffectiveSystemStiffnessMatrix(problem, M, D, K);

    for timeStep = 1 : problem.dynamics.nTimeSteps

        disp(['Time step ', num2str(timeStep), '/', num2str(problem.dynamics.nTimeSteps)]);

        % extract necessary quantities from solution
        if mod(timeStep,timeStepFactor)==0
            data.displacementAtLastNode(timeStep/timeStepFactor) = UDynamic(end);
            data.displacementAtMiddleNode1(timeStep/timeStepFactor) = UDynamic(middle1);
            data.displacementAtMiddleNode2(timeStep/timeStepFactor) = UDynamic(middle2);
        end
        
        % calculate effective force vector
        [ FEff ] = cdmEffectiveSystemForceVector(problem, M, D, K, F, UDynamic, UOldDynamic);

        time = problem.dynamics.tStart + (timeStep-1) * problem.dynamics.tStop / problem.dynamics.nTimeSteps;
        last = size(problem.nodes,2);
        FEff(last) = FEff(last) + fExt(time);

        % solve linear system of equations (UNewDynamic = KEff \ FEff)
        UNewDynamic = moSolveSparseSystem( KEff, FEff );

        % calculate velocities and accelerations
        %[ VDynamic, ADynamic ] = cdmVelocityAcceleration(problem, UNewDynamic, UDynamic, UOldDynamic);

        % update kinematic quantities
        [ UDynamic, UOldDynamic ] = cdmUpdateKinematics(UNewDynamic, UDynamic);

    end


end