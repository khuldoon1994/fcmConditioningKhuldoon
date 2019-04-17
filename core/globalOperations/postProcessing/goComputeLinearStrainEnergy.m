function [ energies ] = goComputeLinearStrainEnergy( problem, allUe )

    nElements = numel(problem.elementTypeIndices);
    energies = zeros(nElements,1);
    for iElement = 1:nElements
        energies(iElement) = eoIntegrateSolutionFunction(problem, iElement, allUe{iElement}, @linearStrainEnergyDensity);
    end

end

function energyDensity = linearStrainEnergyDensity(problem, elementIndex, localCoordinates,...
    jacobian, jacobianDeterminant, dofSolution)
    
    % get local derivative
    shapeFunctionLocalDerivatives = ...
        eoEvaluateShapeFunctionLocalDerivatives(problem, elementIndex, localCoordinates);
    
    % compute global derivatives
    inverseJacobian = moPseudoInverse(jacobian);
    shapeFunctionGlobalDerivatives = inverseJacobian' * shapeFunctionLocalDerivatives;
    
    % compute strain
    B = moComposeStrainDisplacementMatrix(shapeFunctionGlobalDerivatives);
    strain = B * dofSolution;    
    
    % elasticity matrix
    elementTypeIndex = problem.elementTypeIndices(elementIndex);
    elasticityMatrixGetter = problem.elementTypes{elementTypeIndex}.elasticityMatrixGetter;
    C = elasticityMatrixGetter(problem, elementIndex, localCoordinates);
        
    % srain energy densitry
    energyDensity = 0.5 * strain' * C * strain;
    
end