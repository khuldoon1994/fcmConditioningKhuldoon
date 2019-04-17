function [ shapeFunctionGlobalDerivatives ] = ...
    eoEvaluateShapeFunctionGlobalDerivative( problem, elementIndex, localCoordinates)
    
    % get local derivative
    shapeFunctionLocalDerivatives = ...
        eoEvaluateShapeFunctionLocalDerivatives(problem, elementIndex, localCoordinates);
    
    % get jacobian and its inverse
    jacobian = eoEvaluateJacobian(problem, elementIndex, localCoordinates);
    inverseJacobian = moPseudoInverse(jacobian);
    
    % calculate global derivatives
    shapeFunctionGlobalDerivatives = inverseJacobian' * shapeFunctionLocalDerivatives;
end

