function [ X ] = myBlendedLineMapping( problem, elementIndex, localCoordinates )

  nodes = problem.nodes(:,problem.elementNodeIndices{elementIndex});

  r = localCoordinates;
  
  if elementIndex == 3
    X = [ 2 * cos(pi/4.0*r); 2 * sin(pi/4.0*r)];
  else
    X = 0.5*(1-r)*nodes(:,1)+0.5*(1+r)*nodes(:,2);
  end
end