function [ X ] = linearQuadMapping( problem, elementIndex, localCoordinates )

  nodes = problem.nodes(:,problem.elementNodeIndices{elementIndex});

  shapeFunctions = linearQuadShapeFunctions(problem, elementIndex, localCoordinates, 0);

  X = nodes * shapeFunctions';
 
end