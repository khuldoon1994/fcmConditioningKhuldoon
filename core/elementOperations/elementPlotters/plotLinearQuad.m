function [ handle ] = plotLinearQuad(  problem, elementIndex )

  nodes = problem.nodes(:, problem.elementNodeIndices{elementIndex});
  fullNodes = moMakeFull(nodes,3,0);

%  center = 0.25*sum(fullNodes')';
%  for i=1:4
%     fullNodes(:,i) = fullNodes(:,i) - 0.2 *  (fullNodes(:,i) - center);
%  end
  
  %fullNodes = [ fullNodes(:,1),  fullNodes(:,2),  fullNodes(:,4),  fullNodes(:,3),  fullNodes(:,1) ];
  %plot3(fullNodes(1,:), fullNodes(2,:), fullNodes(3,:), 'k-', 'linewidth', 1 );
  
  
  fullNodes = [ fullNodes(:,1),  fullNodes(:,2),  fullNodes(:,4),  fullNodes(:,3) ]';
  f = [1 2 3 4];
  c = [0.5 0.5 0.5];
  handle = patch('Faces',f,'Vertices',fullNodes,'FaceColor',c,'EdgeColor','black', 'linewidth', 1);

end

