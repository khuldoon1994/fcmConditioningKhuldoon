function [ handle ] = plotPoint( problem, elementIndex )
  
  node = problem.nodes(:, problem.elementNodeIndices{elementIndex});
  
  fullNodes = moMakeFull(node,3,0);

  handle = plot3(fullNodes(1,:), fullNodes(2,:), fullNodes(3,:), 'ko', 'linewidth', 2 );

end