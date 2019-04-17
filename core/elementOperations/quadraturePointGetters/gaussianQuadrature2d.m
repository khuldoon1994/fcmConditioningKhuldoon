function [ points, weights ] = gaussianQuadrature2d( problem, elementIndex )
    
    [ points1d, weights1d ] = gaussianQuadrature1d( problem, elementIndex );
    
    order = numel(points1d);
    
    points=zeros(2,order*order);
    weights=zeros(1,order*order);
    for i=1:order
        for j=1:order
            points(:,(i-1)*order+j) = [ points1d(i); points1d(j) ];
            weights((i-1)*order+j) = weights1d(i)*weights1d(j);
        end
    end
    
end

