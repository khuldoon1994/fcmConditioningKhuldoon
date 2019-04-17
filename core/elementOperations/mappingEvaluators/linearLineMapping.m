function [ X ] = linearLineMapping( problem, elementIndex, localCoordinates )

  nodes = problem.nodes(:,problem.elementNodeIndices{elementIndex});

  r = localCoordinates;
  
  X = 0.5*(1-r)*nodes(:,1)+0.5*(1+r)*nodes(:,2);
  
end