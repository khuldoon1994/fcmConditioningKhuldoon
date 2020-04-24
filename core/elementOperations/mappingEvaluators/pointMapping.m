function [ globalCoordinates ] = pointMapping( problem, elementIndex, localCoordinates )
  
  globalCoordinates = problem.nodes(:, problem.elementNodeIndices{elementIndex});
  
end