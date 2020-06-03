function [ Ke, Fe ] = boundarySystemMatricesCreator(problem, elementIndex)
    % gather some information
    elementTypeIndex = problem.elementTypeIndices(elementIndex);
    nDof = eoGetNumberOfShapeFunctions(problem,elementIndex) * problem.dimension;
    elementType = problem.elementTypes{elementTypeIndex};
    
    % initialize matrices
    Ke=zeros(nDof,nDof);
    Fe=zeros(nDof,1);

    % gather dimension related quantities
    if (elementType.localDimension == 1)
        thickness = elementType.thickness;
    end

    % create quadrature points
    quadraturePointGetter = elementType.quadraturePointGetter;
    [ points, weights ] = quadraturePointGetter(problem, elementIndex);
    
    % loop over quadrature points
    nPoints = numel(weights);
    for i=1:nPoints
        
        % copy the local coordinates of this quadrature point
        localCoordinates = points(:,i);
        
        % shape functions and mapping evaluation
        shapeFunctions = eoEvaluateShapeFunctions(problem, elementIndex, localCoordinates);
        jacobian = eoEvaluateJacobian(problem,elementIndex,localCoordinates);
        detJ = moPseudoDeterminant(jacobian);
        
        % simplify integrand
        if (elementType.localDimension == 1)
            detJ = detJ * thickness;
        end
           
        % add load vector integrand
        N = moComposeInterpolationMatrix(problem.dimension,shapeFunctions);
        b = eoEvaluateTotalLoad(problem, elementIndex, localCoordinates);
        Fe = Fe + N' * b * weights(i) * detJ;
        
    end

    % add penalty contribution
    [ Kp, Fp ] = eoGetPenaltySystemMatrices(problem, elementIndex);
    Ke = Ke + Kp;
    Fe = Fe + Fp;

end