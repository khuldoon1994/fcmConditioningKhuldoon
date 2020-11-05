function [ X ] = myBlendedQuadMapping2( problem, elementIndex, localCoordinates, R )

  nodes = problem.nodes(:,problem.elementNodeIndices{elementIndex});

  shapeFunctions = linearQuadShapeFunctions(problem, elementIndex, localCoordinates, 0);

  r = localCoordinates(1);
  s = localCoordinates(2);
  
  E3 = [ 100 - R*(cos(pi*((s+1.0)/2.0)/4.0)); R* (sin(pi*((s+1.0)/2)/4.0)) ];
  
  X = nodes * shapeFunctions' + ( E3 - (1.0-s)/2.0 * nodes(:,2) - (1.0+s)/2.0 * nodes(:,3)) * (1+r)/2.0;
 
end