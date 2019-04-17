function goPlotPenalties( problem, fig )

    figure(fig);
    hold on;
    
    %% nodal penalties
    nNodes = size(problem.nodes,2);
    constrainedNodes = zeros(1,nNodes);
    nConstrainedNodes = 0;
    for iNode=1:nNodes
        if(numel(problem.nodePenalties{iNode})>0)
            constrainedNodes(iNode)=1;
            nConstrainedNodes = nConstrainedNodes+1;
        end
    end
    
    fullNodes = zeros(3,nConstrainedNodes);
    fullNodes(1:problem.dimension,:) = problem.nodes(:,constrainedNodes==1);
    
    plot3( fullNodes(1,:), fullNodes(2,:), fullNodes(3,:), 'ro', 'markers', 10, 'linewidth', 2 );

    
    %% element penalties
    nElements = numel(problem.elementNodeIndices);
    for iElement=1:nElements
        if(numel(problem.elementPenalties{iElement})>0)
            
            elementTypeIndex = problem.elementTypeIndices(iElement);
                        
            nPoints=10;
            r = linspace(-1+2/(nPoints+1),1-2/(nPoints+1),nPoints);
            for i=1:nPoints
                position = problem.elementTypes{elementTypeIndex}.mappingEvaluator(problem, iElement,r(i));
                position = moMakeFull(position,3,0);
                plot3(position(1), position(2), position(3),'rx','LineWidth',2, 'markers', 10);
            end

        end
    end

    
end