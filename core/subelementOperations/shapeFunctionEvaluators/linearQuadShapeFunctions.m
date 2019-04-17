function [ shapeFunctions ] = linearQuadShapeFunctions( problem, elementIndex, r, derivative )
%LINEARQUADSHAPEFUNCTIONS Summary of this function goes here
%   Detailed explanation goes here

if derivative==0
    
    shapeFunctions = [ 0.25*(1-r(1))*(1-r(2)), 0.25*(1+r(1))*(1-r(2)), 0.25*(1-r(1))*(1+r(2)), 0.25*(1+r(1))*(1+r(2)) ];

elseif derivative==1
    
    shapeFunctions = [ -0.25*(1-r(2))  0.25*(1-r(2)) -0.25*(1+r(2))  0.25*(1+r(2));
                       -0.25*(1-r(1)) -0.25*(1+r(1))  0.25*(1-r(1))  0.25*(1+r(1))];
else
    
    disp('ERROR! Linear quad shape functions can only handle first derivative.');
    
end

end

