function [ shapeFunctions ] = linearLineShapeFunctions( problem, elementIndex, r, derivative )

if derivative==0
  shapeFunctions = [ 0.5*(1-r), 0.5*(1+r) ];
elseif derivative==1
  shapeFunctions = [ -0.5, 0.5 ];
else
  shapeFunctions = [ 0, 0 ];  
end

end