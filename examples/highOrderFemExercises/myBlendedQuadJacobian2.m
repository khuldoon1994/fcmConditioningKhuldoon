function [ jacobian ] = myBlendedQuadJacobian2( problem, elementIndex, localCoordinates )
%myBlendedQuadJacobian Evaluates the jacobian matrix for a blended quad.

    nodes = problem.nodes(:,problem.elementNodeIndices{elementIndex});
    
    r = localCoordinates;
    
    shapeFunctionLocalDerivatives = [ -0.25*(1-r(2))  0.25*(1-r(2)) -0.25*(1+r(2))  0.25*(1+r(2));
                                      -0.25*(1-r(1)) -0.25*(1+r(1))  0.25*(1-r(1))  0.25*(1+r(1)) ];
    
    jacobian = zeros(problem.dimension, 2);
    for iShape=1:4
        jacobian = jacobian + nodes(:,iShape) * shapeFunctionLocalDerivatives(:,iShape)';
    end

    s=r(2);
    r=r(1);
    
    E3 = [ 100 - R*(cos(pi*((s+1.0)/2.0)/4.0)); R* (sin(pi*((s+1.0)/2)/4.0)) ];
    dE3ds = [- R*(pi/8.0)*(sin(pi*((s+1.0)/2.0)/4.0)); R*(pi/8.0)*(sin(pi*((s+1.0)/2)/4.0))];
    
    jacobian = jacobian + [( E3 - (1.0-s)/2.0 * nodes(:,2) - (1.0+s)/2.0 * nodes(:,3)) * 1.0/2.0,  ...
                           ( dE3ds + 1.0/2.0 * nodes(:,2) - 1.0/2.0 * nodes(:,3)) * (1+r)/2.0 ];
 
end
