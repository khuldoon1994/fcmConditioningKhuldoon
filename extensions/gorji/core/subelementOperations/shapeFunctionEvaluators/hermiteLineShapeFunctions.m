function [ shapeFunctions ] = hermiteLineShapeFunctions( problem, elementIndex, r, derivative )

if derivative==0
  shapeFunctions = [ 0.25*(1-r^2)*(r+2), 0.25*(1-r^2)*(r+1), 0.25*(1+r^2)*(r+2), 0.25*(1+r^2)*(r-1) ];
elseif derivative==1
  shapeFunctions = [ 1/4 - (3*r^2)/4 - r, 1/4 - (3*r^2)/4 - r/2, (3*r^2)/4 + r + 1/4, (3*r^2)/4 - r/2 + 1/4];
elseif derivative==2
  shapeFunctions = [ - (3*r)/2 - 1, - (3*r)/2 - 1/2, (3*r)/2 + 1, (3*r)/2 - 1/2];
else
  shapeFunctions = [ 0, 0 ];  
end

end