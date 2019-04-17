function goPlotBasicCell( problem, topology, nodes, solution, deformation )

    %% prepare data
    nNodes = size(nodes,2);

    % make everythign 3d
    fullNodes = moMakeFull(nodes,3,0);
    fullDeformation = moMakeFull(deformation,3,0);
    
    % make solution 1d if not already
    solution1d = zeros(1,nNodes);
    if size(solution,1)>1
        for i=1:nNodes
            solution1d(i) = norm(solution(:,i));
        end
    else
        solution1d = solution;
    end
       
    %% plot cell
    % line
    if topology==1
    
        % plot undeformed cell
        if norm(deformation)>0
            c = [0.5 0.5 0.5];
            %plot3(fullNodes(1,:), fullNodes(2,:), fullNodes(3,:), 'b-', 'linewidth', 1, 'Color', c );
        end
        
        % deform and reorder nodes
        fullNodes = fullNodes + fullDeformation + rand(3,nNodes)*1e-6;
        
        %patch(fullNodes(1,:), fullNodes(2,:), fullNodes(3,:), solution1d, 'FaceColor', 'none', 'EdgeColor', 'interp');
                
        x=linspace(fullNodes(1,1),fullNodes(1,2),10);
        y=linspace(fullNodes(2,1),fullNodes(2,2),10);
        z=linspace(fullNodes(3,1),fullNodes(3,2),10);
        c=linspace(solution1d(1,1),solution1d(1,2),10);

        patch(x,y,z,c,'FaceColor','none','EdgeColor','interp', 'LineWidth',3)

    % quad
    elseif topology==2
    
        % plot undeformed cell
        if norm(deformation)>0
            f = [1 2 3 4];
            c = [0.5 0.5 0.5];
            fullNodesTemp = [ fullNodes(:,1),  fullNodes(:,2),  fullNodes(:,4),  fullNodes(:,3) ]';
            patch('Faces',f,'Vertices',fullNodesTemp,'FaceColor','none','EdgeColor',c, 'linewidth', 1);
        end
        
        % deform and reorder nodes
        fullNodes = fullNodes + fullDeformation;
        fullNodes = [ fullNodes(:,1),  fullNodes(:,2),  fullNodes(:,4),  fullNodes(:,3) ];
        
        % reorder solution
        solution1d = [ solution1d(1),  solution1d(2),  solution1d(4),  solution1d(3) ];
        %solution1d = [ fullDeformation(1,1),  fullDeformation(1,2),  fullDeformation(1,4),  fullDeformation(1,3) ];
        
        patch(fullNodes(1,:),fullNodes(2,:),fullNodes(3,:), solution1d, 'linewidth', 2);
    
    else
        
        disp(['ERROR! plotBasicCell(...) cannot handle topology ', num2str(topology), '.']);

    end

    

 
end

