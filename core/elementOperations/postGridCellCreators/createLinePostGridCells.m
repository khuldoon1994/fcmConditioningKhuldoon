function [ postGridCells ] = createLinePostGridCells( problem, elementIndex, cuts )
% createLinePostGridCells Creates post grid cells for a line element.

    % get mapping evaluator
    elementTypeIndex = problem.elementTypeIndices{elementIndex}(2);
    mappingEvaluator = problem.elementTypes{elementTypeIndex}.mappingEvaluator;

    % local coordinates of the new nodes
    r=linspace(-1,1,cuts+2);
    
    % create new nodes
    postGridNodesGlobal = zeros(problem.dimension,cuts+2);
    postGridNodesLocal = zeros(1,cuts+2);
    for iNode=1:cuts+2
        postGridNodesLocal(:,iNode) = r(i);
        postGridNodesGlobal(:,iNode) = mappingEvaluator(problem, elementIndex, r(i));
    end

    % create new cells
    nPostGridCells = (cuts+1);
    postGridCells=cell(nPostGridCells,1);
    for iCell=1:cuts+1
        cellNodeGlobalPositions = postGridNodesGlobal(:,[iCell iCell+1]);
        cellNodeLocalPositions = postGridNodesLocal(:,[iCell iCell+1]);
        postGridCells{iCell} = { 1, cellNodeGlobalPositions, elementIndex, cellNodeLocalPositions };
    end
    
end
