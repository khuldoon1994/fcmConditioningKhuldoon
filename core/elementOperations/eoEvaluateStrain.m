function strain = eoEvaluateStrain(problem, elementIndex, dofSolution, localCoordinates)
% eoEvaluateStrain computes the strain within an element
%
%   strain = eoEvaluateStrain(problem, elementIndex, dofSolution, localCoordinates)
%   evaluates the shape function of element elmentIndex at localCoordinates
%   and uses the result to compute solution from the dofSolution.
%
%   Note: The number of degrees of freedom per element is the number of shape
%   functions times the problem dimension (in a structural mechanics
%   analysis). the column vector dofSolution must have as many entries.

nPoints = size(localCoordinates,2);
strain = zeros(problem.dimension+1, nPoints);

for i=1:nPoints
      r = localCoordinates(:,i);
    shapeFunctionLocalDerivatives = ...
        eoEvaluateShapeFunctionLocalDerivatives(problem, elementIndex, localCoordinates);

    % compute global derivatives
    jacobian = eoEvaluateJacobian(problem,elementIndex,r);
    inverseJacobian = moPseudoInverse(jacobian);
    shapeFunctionGlobalDerivatives = inverseJacobian' * shapeFunctionLocalDerivatives;

    % compute strain
    B = moComposeStrainDisplacementMatrix(shapeFunctionGlobalDerivatives);

    strain(:,i) = B * dofSolution;
end

end