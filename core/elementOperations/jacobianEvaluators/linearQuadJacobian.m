function [ jacobian ] = linearQuadJacobian( problem, elementIndex, localCoordinates )
%linearQuadJacobian2d Evaluates the jacobian matrix for a linear quad.

    nodes = problem.nodes(:,problem.elementNodeIndices{elementIndex});
    
    r = localCoordinates;
    
    shapeFunctionLocalDerivatives = [ -0.25*(1-r(2))  0.25*(1-r(2)) -0.25*(1+r(2))  0.25*(1+r(2));
                                      -0.25*(1-r(1)) -0.25*(1+r(1))  0.25*(1-r(1))  0.25*(1+r(1)) ];
    
    jacobian = zeros(problem.dimension, 2);
    for iShape=1:4
        jacobian = jacobian + nodes(:,iShape) * shapeFunctionLocalDerivatives(:,iShape)';
    end
    
end

