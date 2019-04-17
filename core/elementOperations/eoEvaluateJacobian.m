function jacobian = eoEvaluateJacobian(problem,elementIndex,localCoordinates)
% eoEvaluateJacobian Evaluates the Jacobian matrix for an element

  elementTypeIndex = problem.elementTypeIndices(elementIndex);
  jacobianEvaluator = problem.elementTypes{elementTypeIndex}.jacobianEvaluator;
  jacobian = jacobianEvaluator(problem,elementIndex,localCoordinates);

end