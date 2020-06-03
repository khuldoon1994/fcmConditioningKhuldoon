function [ Ke, Fe ] = standardSystemMatricesCreator(problem, elementIndex)
% standardSystemMatricesCreator creates the linear elastic stiffness matrix
% and load vector for an n-dimensional continuum element.

    % gather some information
    elementTypeIndex = problem.elementTypeIndices(elementIndex);
    nDof = eoGetNumberOfShapeFunctions(problem,elementIndex) * problem.dimension;
    elementType = problem.elementTypes{elementTypeIndex};
    
    % initialize matrices
    Ke=zeros(nDof,nDof);
    Fe=zeros(nDof,1);

    % create copy of function handles for shorter notation
    quadraturePointGetter = elementType.quadraturePointGetter;
    elasticityMatrixGetter = elementType.elasticityMatrixGetter;

    % gather dimension related quantities
    if (elementType.localDimension == 2)
        thickness = elementType.thickness;
    elseif (elementType.localDimension == 1)
        area = elementType.area;
    end
    
    % create quadrature points
    [ points, weights ] = quadraturePointGetter(problem, elementIndex);
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
        
        % simplify integrand
        if (elementType.localDimension == 2)
            detJ = detJ * thickness;
        elseif (elementType.localDimension == 1)
            detJ = detJ * area;
        end
        
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
