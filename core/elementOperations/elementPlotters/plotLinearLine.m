function [ handle ] = plotLinearLine( problem, elementIndex )
  
  nodes = problem.nodes(:, problem.elementNodeIndices{elementIndex});
  
  fullNodes = moMakeFull(nodes,3,0);

  handle = plot3(fullNodes(1,:), fullNodes(2,:), fullNodes(3,:), 'k-', 'linewidth', 2 );

end