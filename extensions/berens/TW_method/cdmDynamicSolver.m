function [ solutionQuantities ] = cdmDynamicSolver(problem, solutionPointer, globalMatrices, globalInitialValues)
%calculate solution quantities with the Central Difference Method
    
    nTimeSteps = problem.dynamics.nTimeSteps;
    nQuantities = numel(solutionPointer);
    
    % initialize solution quantities and quantity location vectors
    solutionQuantities = cell(size(solutionPointer));
    allLq = cell(size(solutionPointer));
    
    for iQuantity = 1:nQuantities
        currentPointer = solutionPointer{iQuantity};
        quantityLocationVector = currentPointer{2};
        % create quantitylocation vector
        allLq{iQuantity} = goCreateQuantityLocationVector(problem, quantityLocationVector);
        % initialize solution quantities
        solutionQuantities{iQuantity} = zeros(length(allLq{iQuantity}), nTimeSteps);
    end
    
    % extract matrices and vectors from globalMatrices
    M = globalMatrices{1};
    D = globalMatrices{2};
    K = globalMatrices{3};
    F = globalMatrices{4};
    
    % extract initial values from globalInitialValues
    U0Dynamic = globalInitialValues{1};
    V0Dynamic = globalInitialValues{2};
    A0Dynamic = globalInitialValues{3};
    
    % initialize values
    [ UOldDynamic, UDynamic, VDynamic, ADynamic ] = cdmInitialize(problem, U0Dynamic, V0Dynamic, A0Dynamic);
    
    % create effective system matrices
    [ KEff ] = cdmEffectiveSystemStiffnessMatrix(problem, M, D, K);
    
    for iTimeStep = 1:nTimeSteps
        
        % extract necessary quantities from solution
        for iQuantity = 1:nQuantities
            currentPointer = solutionPointer{iQuantity};
            quantityName = currentPointer{1};
            quantityDynamic = goChooseQuantity(UDynamic, VDynamic, ADynamic, quantityName);
            solutionQuantities{iQuantity}(:, iTimeStep) = quantityDynamic(allLq{iQuantity});
        end
        
        % calculate effective force vector
        [ FEff ] = cdmEffectiveSystemForceVector(problem, M, D, K, F, UDynamic, UOldDynamic);
        
        % solve linear system of equations (UNewDynamic = KEff \ FEff)
        UNewDynamic = moSolveSparseSystem( KEff, FEff );
        
        % calculate velocities and accelerations
        [ VDynamic, ADynamic ] = cdmVelocityAcceleration(problem, UNewDynamic, UDynamic, UOldDynamic);
        
        % update kinematic quantities
        [ UDynamic, UOldDynamic ] = cdmUpdateKinematics(UNewDynamic, UDynamic);
        
    end
    
end
