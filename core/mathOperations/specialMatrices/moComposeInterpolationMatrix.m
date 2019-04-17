function [ N ] = moComposeInterpolationMatrix(dimensions,shapeFunctions)
% moComposeInterpolationMatrix Composes the standard finite element
% interpolation matrix N containing the shape functions such that u = N U.

    nDof=size(shapeFunctions,2)*dimensions;

    N=zeros(dimensions,nDof);

    for i=1:dimensions
      N(i,i:dimensions:nDof) = shapeFunctions;
    end

end