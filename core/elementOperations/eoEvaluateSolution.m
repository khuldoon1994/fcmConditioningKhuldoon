function solution = eoEvaluateSolution(problem, elementIndex, dofSolution, localCoordinates)
% eoEvaluateSolution computes the solution within an element
%
%   solution = eoEvaluateSolution(problem, elementIndex, dofSolution, localCoordinates)
%   evaluates the shape function of element elmentIndex at localCoordinates
%   and uses the result to compute solution from the dofSolution.
%
%   Note: The number of degrees of freedom per element is the number of shape
%   functions times the problem dimension (in a structural mechanics
%   analysis). the column vector dofSolution must have as many entries.

  nPoints = size(localCoordinates,2);
  solution = zeros(problem.dimension, nPoints);
  
  for i=1:nPoints
      r = localCoordinates(:,i);
      shapeFunctions = eoEvaluateShapeFunctions(problem, elementIndex, r);
      N = moComposeInterpolationMatrix(problem.dimension,shapeFunctions);
      solution(:,i) = N * dofSolution;
  end
     
end