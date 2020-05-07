function [ Me, Ke, Fe ] = truss2dDynamicSystemMatricesCreator(problem, elementIndex)

    % gather some information
    elementTypeIndex = problem.elementTypeIndices(elementIndex);
    nDof = 2 * problem.dimension;
    
    % structure
    E = problem.elementTypes{elementTypeIndex}.youngsModulus;
    A = problem.elementTypes{elementTypeIndex}.area;
    rho = problem.elementTypes{elementTypeIndex}.massDensity;
    
    % geometry
    i1 = problem.elementNodeIndices{elementIndex}(1);
    n1 = problem.nodes(:, i1);
    i2 = problem.elementNodeIndices{elementIndex}(2);
    n2 = problem.nodes(:, i2);
    d = n2 - n1;
    L = norm(d);
    
    % sine and cosines
    c = d(1)/L;
    s = d(2)/L;
    sc = s*c;
    s2 = s*s;
    c2 = c*c;
    
    % element matrices
    Ke = E*A/L*[c2 sc -c2 -sc; sc s2 -sc -s2; -c2 -sc c2 sc; -sc -s2 sc s2];
    Me = rho*A*L/6*[2*c2 2*sc c2 sc; 2*sc 2*s2 sc s2; c2 sc 2*c2 2*sc; sc s2 2*sc 2*s2];
        
    % load vector
    Fe = zeros(4,1);
    if numel(problem.elementLoads{elementIndex})>=1
         % create quadrature points
        [ points, weights ] = quadraturePointGetter(problem, elementIndex);
        nPoints = numel(weights);

        % loop over quadrature points
        for i=1:nPoints

            % copy the local coordinates of this quadrature point
            localCoordinates = points(:,i);

            % shape functions and mapping evaluation
            shapeFunctions = eoEvaluateShapeFunctions(problem, elementIndex, localCoordinates);
             jacobian = eoEvaluateJacobian(problem,elementIndex,localCoordinates);
            detJ = det(jacobian);

            % add load vector integrand
            N = moComposeInterpolationMatrix(problem.dimension,shapeFunctions);
            b = eoEvaluateTotalLoad(problem, elementIndex, localCoordinates);
            Fe = Fe + N'*b * weights(i) * detJ;

        end
    end
end