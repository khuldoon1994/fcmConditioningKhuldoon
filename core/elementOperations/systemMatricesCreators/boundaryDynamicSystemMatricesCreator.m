function [ Me, De, Ke, Fe ] = boundaryDynamicSystemMatricesCreator(problem, elementIndex)

    % gather some information
    elementTypeIndex = problem.elementTypeIndices(elementIndex);
    nDof = eoGetNumberOfShapeFunctions(problem,elementIndex) * problem.dimension;
    
    % initialize matrices
    Ke = zeros(nDof,nDof);
    De = zeros(nDof,nDof);
    Me = zeros(nDof,nDof);
    Fe = zeros(nDof,1);

    % create quadrature points
    quadraturePointGetter = problem.elementTypes{elementTypeIndex}.quadraturePointGetter;
    [ points, weights ] = quadraturePointGetter(problem, elementIndex);
    
    % loop over quadrature points
    nPoints = numel(weights);
    for i=1:nPoints
        
        % copy the local coordinates of this quadrature point
        localCoordinates = points(:,i);
        
        % shape functions and mapping evaluation
        shapeFunctions = eoEvaluateShapeFunctions(problem, elementIndex, localCoordinates);
        jacobian = eoEvaluateJacobian(problem,elementIndex,localCoordinates);
           
        % add load vector integrand
        N = moComposeInterpolationMatrix(problem.dimension,shapeFunctions);
        b = eoEvaluateTotalLoad(problem, elementIndex, localCoordinates);
        Fe = Fe + N' * b * weights(i) * moPseudoDeterminant(jacobian);
        
    end
    
end