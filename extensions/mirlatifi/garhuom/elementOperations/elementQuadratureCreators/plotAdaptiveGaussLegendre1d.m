function plotAdaptiveGaussLegendre1d( problem, figID )
%plotAdaptiveGaussLegendre1d Summary of this function goes here
%   Detailed explanation goes here

figure(figID)
grid on
hold on
%% plot spacetree
for i=1:length(problem.elementQuadratures)
    
    iElementType = problem.elementTypeIndices(i);
    elementType = problem.elementTypes{iElementType};

    lineTree = problem.elementQuadratures{i}.spaceTree;
    
    % plot node of element
    minmax=[-1 1];
    for j=1:2
    Xnodes(:,j) = elementType.mappingEvaluator(problem, i, minmax(j));
    end
    plot(Xnodes,[0 0],'k-s','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',12)
    
    % plot inside cells
    insideElements = lineTree.insideElements;
    if ~isempty(insideElements)
        for j=1:length(insideElements)
            element = insideElements{j};
            Rnodes = element.nodesMinMax;
            for k=1:2
            Xnodes(:,k) = elementType.mappingEvaluator(problem, i, Rnodes(k));
            end
            plot(Xnodes,[0 0],'b-+','MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize',10)
        end
    end
    
%     % plot outside cells
%     outsideElements = lineTree.outsideElements;
%     if ~isempty(outsideElements)
%         for j=1:length(outsideElements)
%             element = outsideElements{j};
%             Rnodes = element.nodesMinMax;
%             Xnodes = elementType.mappingEvaluator(problem, i, Rnodes);
%             plot(Xnodes,[0 0],'g-+','MarkerEdgeColor','g','MarkerFaceColor','g','MarkerSize',10)
%         end
%     end
    
    % plot broken cells
    brokenElements = lineTree.brokenElements;
    if ~isempty(brokenElements)
        for j=1:length(brokenElements)
            element = brokenElements{j};
            Rnodes = element.nodesMinMax;
            for k=1:2
            Xnodes(:,k) = elementType.mappingEvaluator(problem, i, Rnodes(k));
            end
            plot(Xnodes,[0 0],'r-+','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',10)
        end
    end
end

%% plot integration points
for i=1:length(problem.elementQuadratures)
    
    iElementType = problem.elementTypeIndices(i);
    elementType = problem.elementTypes{iElementType};
    
    localPoints = problem.elementQuadratures{i}.points;
    
    for j=1:length(localPoints)
    globalPoints(:,j) = elementType.mappingEvaluator(problem, i, localPoints(j));
    end
    
    plot(globalPoints,zeros(1,length(globalPoints)),'kx','MarkerSize',6)
end
hold off

end

