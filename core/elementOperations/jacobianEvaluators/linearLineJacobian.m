function [ jacobian ] = linearLineJacobian( problem, elementIndex, localCoordinates )
%linearLineJacobian1d Evaluates the jacobian matrix for a linear line.

    nodeIndices = problem.elementNodeIndices{elementIndex};
    nodes = problem.nodes(:,nodeIndices);
    jacobian = -0.5*nodes(:,1) + 0.5*nodes(:,2);
    
end

