function [ Ke, Fe ] = eoStandardSystemMatricesCreator(problem, elementIndex)

    % gather some information
    elementTypeIndex = problem.elementTypeIndices(elementIndex);
    nDof = eoGetNumberOfShapeFunctions(problem,elementIndex) * problem.dimension;
    
    % initialize matrices
    Ke=zeros(nDof,nDof);
    Fe=zeros(nDof,1);

    % create copy of function handles for shorter notation
%    quadraturePointGetter = problem.elementTypes{elementTypeIndex}.quadraturePointGetter;
    elasticityMatrixGetter = problem.elementTypes{elementTypeIndex}.elasticityMatrixGetter;

    % create quadrature points
%    [ points, weights ] = quadraturePointGetter(problem, elementIndex);
    points = problem.elementQuadratures{elementIndex}.points;
    weights = problem.elementQuadratures{elementIndex}.weights;
    
    nPoints = numel(weights);

    % loop over quadrature points
    for i=1:nPoints
        
        % copy the local coordinates of this quadrature point
        localCoordinates = points(:,i);
        
        % shape functions and mapping evaluation
        shapeFunctions = eoEvaluateShapeFunctions(problem, elementIndex, localCoordinates);
        shapeFunctionGlobalDerivatives = eoEvaluateShapeFunctionGlobalDerivative(problem,elementIndex,localCoordinates);
        jacobian = eoEvaluateJacobian(problem,elementIndex,localCoordinates);
        detJ = det(jacobian);
        
        % add stiffness matrix integrand
        B = moComposeStrainDisplacementMatrix(shapeFunctionGlobalDerivatives);
        C = elasticityMatrixGetter(problem, elementIndex, localCoordinates);
        Ke = Ke + B'*C*B * weights(i) * detJ;
        
        % add load vector integrand
        N = moComposeInterpolationMatrix(problem.dimension,shapeFunctions);
        b = eoEvaluateTotalLoad(problem, elementIndex, localCoordinates);
        Fe = Fe + N'*b * weights(i) * detJ;
        
        % add elastic foundation integrand
        c = eoEvaluateTotalFoundationStiffness(problem, elementIndex, localCoordinates);
        Ke = Ke + N'* c * N * weights(i) * detJ;
    end

    % add penalty constraints
    [ Kp, Fp ] = eoGetPenaltySystemMatrices(problem, elementIndex);
    Ke = Ke + Kp;
    Fe = Fe + Fp;
   
end
