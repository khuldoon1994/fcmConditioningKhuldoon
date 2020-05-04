function plotColoredLinearLine( problem, cell, Ue )


    nodes = problem.nodes(:, problem.elements{elementTypeIndex}(:,elementIndex));
    fullNodes = zeros(3,size(nodes,2));
    fullNodes(1:problem.dimension,:) = nodes;

    matrixUe = reshape(Ue,problem.dimension, numel(Ue)/problem.dimension);
    fullUe = zeros(3,size(matrixUe,2));
    fullUe(1:problem.dimension,:) = matrixUe;
    colors = [ norm(fullUe(1:3)), norm(fullUe(4:6)) ];

    
   
    colors=fullNodes(1,1):0.01:fullNodes(1,2);
    
    fullNodes = [ fullNodes(1,1):0.01:fullNodes(1,2);
                  zeros(2,101) ];
    
    colormap(hsv);
    patch(fullNodes(1,:), fullNodes(2,:), fullNodes(3,:), colors, 'FaceColor', 'none', 'EdgeColor', 'interp');

    
    t = linspace(0,2*pi,100);
    x = -cos(t);
    y = -sin(t);
    z = t;
    c = cos(t).^2;

    colormap(hsv)
    patch(x,y,z,c,'FaceColor','none','EdgeColor','interp')

 
end