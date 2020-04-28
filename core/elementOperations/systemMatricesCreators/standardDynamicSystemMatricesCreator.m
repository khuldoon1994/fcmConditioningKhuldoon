function [ Me, Ke, Fe ] = standardDynamicSystemMatricesCreator(problem, elementIndex)

    % gather some information
    elementTypeIndex = problem.elementTypeIndices(elementIndex);
    nDof = eoGetNumberOfShapeFunctions(problem,elementIndex) * problem.dimension;
    
    % initialize matrices
    Ke = zeros(nDof,nDof);
    Me = zeros(nDof,nDof);
    Fe = zeros(nDof,1);
    mass = 0;

    % create copy of function handles for shorter notation
    quadraturePointGetter = problem.elementTypes{elementTypeIndex}.quadraturePointGetter;
    elasticityMatrixGetter = problem.elementTypes{elementTypeIndex}.elasticityMatrixGetter;
    dynamicMaterialGetter = problem.elementTypes{elementTypeIndex}.dynamicMaterialGetter;

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
        
        % add stiffness matrix integrand
        B = moComposeStrainDisplacementMatrix(shapeFunctionGlobalDerivatives);
        C = elasticityMatrixGetter(problem, elementIndex, localCoordinates);
        Ke = Ke + B'*C*B * weights(i) * detJ;
        
        % add load vector integrand
        N = moComposeInterpolationMatrix(problem.dimension,shapeFunctions);
        b = eoEvaluateTotalLoad(problem, elementIndex, localCoordinates);
        Fe = Fe + N'*b * weights(i) * detJ;
        
        % add mass matrix integrand (and damping matrix integrand)
        rho = dynamicMaterialGetter(problem, elementIndex, localCoordinates);
        Me = Me + N'*rho*N * weights(i) * detJ;
        
        % add lumped mass integrand
        mass = mass + rho * weights(i) * detJ;
        
        % add elastic foundation integrand
        c = eoEvaluateTotalFoundationStiffness(problem, elementIndex, localCoordinates);
        Ke = Ke + N'* c * N * weights(i) * detJ;
    end
    
    % Mass Lumping
    lumping = problem.dynamics.lumping;
    if(strcmp(lumping, 'Mass Lumping'))
        Me = mass/nDof * eye(nDof);
    end
    
end