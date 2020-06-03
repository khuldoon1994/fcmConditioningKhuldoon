function [ Me, Ke, Fe ] = dynamicTruss2dSystemMatricesCreator(problem, elementIndex)

    % gather some information
    elementTypeIndex = problem.elementTypeIndices(elementIndex);
    nDof = 2 * problem.dimension;
    elementType = problem.elementTypes{elementTypeIndex};
    
    % structure
    E = elementType.youngsModulus;
    A = elementType.area;
    rho = elementType.massDensity;
    
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
    Fe = zeros(4,1);
    
end