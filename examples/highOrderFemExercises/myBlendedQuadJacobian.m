function [ jacobian ] = myBlendedQuadJacobian( problem, elementIndex, localCoordinates )
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
    
    E3 = [ 2 * cos(pi/4.0*s); 2 * sin(pi/4.0*s)];
    dE3ds = [ - 2 * pi/4.0 * sin(pi/4.0*s); 2 * pi/4.0 * cos(pi/4.0*s)];
    
    jacobian = jacobian + [( E3 - (1.0-s)/2.0 * nodes(:,2) - (1.0+s)/2.0 * nodes(:,4)) * 1.0/2.0,  ...
                           ( dE3ds + 1.0/2.0 * nodes(:,2) - 1.0/2.0 * nodes(:,4)) * (1+r)/2.0 ];
 
end

