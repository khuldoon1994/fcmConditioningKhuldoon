function plotLineTree( problem, figID )
%EOPLOTLINETREE Summary of this function goes here
%   Detailed explanation goes here

figure(figID)
hold on
for i=1:length(problem.elementQuadratures)
    
    iElementType = problem.elementTypeIndices(i);
    elementType = problem.elementTypes{iElementType};

    lineTree = problem.elementQuadratures{i}.spaceTree;
    
    % plot node of element
    Xnodes = elementType.mappingEvaluator(problem, i, [-1 1]);
    plot(Xnodes,[0 0],'s','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',12)
    
    % plot inside cells
    insideElements = lineTree.insideElements;
    if ~isempty(insideElements)
        for j=1:length(insideElements)
            element = insideElements{j};
            Rnodes = element.nodesMinMax;
            Xnodes = elementType.mappingEvaluator(problem, i, Rnodes);
            plot(Xnodes,[0 0],'b-+','MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize',10)
        end
    end
    
    % plot outside cells
    outsideElements = lineTree.outsideElements;
    if ~isempty(outsideElements)
        for j=1:length(outsideElements)
            element = outsideElements{j};
            Rnodes = element.nodesMinMax;
            Xnodes = elementType.mappingEvaluator(problem, i, Rnodes);
            plot(Xnodes,[0 0],'g-+','MarkerEdgeColor','g','MarkerFaceColor','g','MarkerSize',10)
        end
    end
    
    % plot broken cells
    brokenElements = lineTree.brokenElements;
    if ~isempty(brokenElements)
        for j=1:length(brokenElements)
            element = brokenElements{j};
            Rnodes = element.nodesMinMax;
            Xnodes = elementType.mappingEvaluator(problem, i, Rnodes);
            plot(Xnodes,[0 0],'r-+','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',10)
        end
    end
end
hold off

end

