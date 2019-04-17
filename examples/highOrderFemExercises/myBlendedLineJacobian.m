function [ jacobian ] = myBlendedLineJacobian( problem, elementIndex, localCoordinates )

    nodeIndices = problem.elementNodeIndices{elementIndex};
    
    nodes = problem.nodes(:,nodeIndices);
    
    if elementIndex == 3
        r = localCoordinates;
        jacobian = [-2.0*pi/4.0*sin(pi/4.0*r); 2.0*pi/4.0*cos(pi/4.0*r) ];
    else
        jacobian = -0.5*nodes(:,1) + 0.5*nodes(:,2);
    end

end