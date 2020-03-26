function [ Me, De, Ke, Fe ] = truss2dDynamicSystemMatricesCreator(problem, elementIndex)

    % gather some information
    elementTypeIndex = problem.elementTypeIndices(elementIndex);
    nDof = 2 * problem.dimension;
    
    % structure
    E = problem.elementTypes{elementTypeIndex}.youngsModulus;
    A = problem.elementTypes{elementTypeIndex}.area;
    rho = problem.elementTypes{elementTypeIndex}.massDensity;
    kappa = problem.elementTypes{elementTypeIndex}.dampingCoefficient;
    
    % geometry
    n1 = problem.nodes(:, problem.elementNodeIndices{elementIndex}(1));
    n2 = problem.nodes(:, problem.elementNodeIndices{elementIndex}(2));
    d = n2 - n1
    L = norm(d);
    
    % sine and cosines
    c = d(1)/L;
    s = d(2)/L;
    sc = s*c;
    s2 = s*s;
    c2 = c*c;
    
    % single dof "matrices"
    Ke = E*A/L*[c2 sc -c2 -sc; sc s2 -sc -s2; -s2 -sc c2 sc; -sc -s2 sc s2];
    Me = 0.5*eye(4)*rho*A*L;
    De = 0.5*eye(4)*kappa*A*L;
    Fe = zeros(4,1);
    
end