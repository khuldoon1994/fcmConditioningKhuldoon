function [ X ] = myBlendedQuadMapping( problem, elementIndex, localCoordinates )

  nodes = problem.nodes(:,problem.elementNodeIndices{elementIndex});

  shapeFunctions = linearQuadShapeFunctions(problem, elementIndex, localCoordinates, 0);

  r = localCoordinates(1);
  s = localCoordinates(2);
  
  E3 = [ 2 * cos(pi/4.0*s); 2 * sin(pi/4.0*s) ];
  
  X = nodes * shapeFunctions' + ( E3 - (1.0-s)/2.0 * nodes(:,2) - (1.0+s)/2.0 * nodes(:,4)) * (1+r)/2.0;
 
end