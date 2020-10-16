function plotQuadTree( problem, figID )
%plotQuadTree Summary of this function goes here
%   Detailed explanation goes here

figure(figID)
hold on
for i=1:length(problem.elementQuadratures)
    
    iElementType = problem.elementTypeIndices(i);
    elementType = problem.elementTypes{iElementType};

    quadTree = problem.elementQuadratures{i}.spaceTree;
    
    % plot quad element
    Rnodes = [-1  1 1 -1 -1 ; -1 -1 1  1 -1];
    Xnodes = zeros(size(Rnodes));
    for iR=1:length(Rnodes)
        Xnodes(:,iR) = elementType.mappingEvaluator(problem, i, Rnodes(:,iR));
    end
    plot(Xnodes(1,:),Xnodes(2,:),'k-s','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',10)
    
    % plot inside cells
    insideElements = quadTree.insideElements;
    if ~isempty(insideElements)
        for j=1:length(insideElements)
            element = insideElements{j};
            nodesMinMax = element.nodesMinMax;
            Rnodes = [nodesMinMax(1,1), nodesMinMax(1,2), nodesMinMax(1,2), nodesMinMax(1,1), nodesMinMax(1,1) ; ...
                      nodesMinMax(2,1), nodesMinMax(2,1), nodesMinMax(2,2), nodesMinMax(2,2), nodesMinMax(2,1)   ];
            Xnodes = zeros(size(Rnodes));
            for iNode=1:length(Xnodes)
                Xnodes(:,iNode) = elementType.mappingEvaluator(problem, i, Rnodes(:,iNode));
            end
            plot(Xnodes(1,:),Xnodes(2,:),'b-')
        end
    end
  
    % plot broken cells
    brokenElements = quadTree.brokenElements;
    if ~isempty(brokenElements)
        for j=1:length(brokenElements)
            element = brokenElements{j};
            nodesMinMax = element.nodesMinMax;
            Rnodes = [nodesMinMax(1,1), nodesMinMax(1,2), nodesMinMax(1,2), nodesMinMax(1,1), nodesMinMax(1,1) ; ...
                      nodesMinMax(2,1), nodesMinMax(2,1), nodesMinMax(2,2), nodesMinMax(2,2), nodesMinMax(2,1)   ];
            Xnodes = zeros(size(Rnodes));
            for iNode=1:length(Xnodes)
                Xnodes(:,iNode) = elementType.mappingEvaluator(problem, i, Rnodes(:,iNode));
            end
            plot(Xnodes(1,:),Xnodes(2,:),'r-')
        end
    end
end
hold off


end

