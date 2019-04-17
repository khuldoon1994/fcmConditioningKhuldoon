function [ postGridCells ] = createQuadPostGridCells( problem, elementIndex, cuts )
% createQuadPostGridCells Creates post grid cells for a quad element.

    % cet element mapping evaluator
    elementTypeIndex = problem.elementTypeIndices(elementIndex);
    mappingEvaluator = problem.elementTypes{elementTypeIndex}.mappingEvaluator;
    
    % one-dimensional local coordinates of new nodes
    r=linspace(-1,1,cuts+2);
        
    % create new nodes
    postGridNodesGlobal = zeros(problem.dimension,(cuts+2)*(cuts+2));
    postGridNodesLocal = zeros(problem.dimension,(cuts+2)*(cuts+2));
    iNode = 1;
    for i=1:cuts+2
        for j=1:cuts+2
            postGridNodesLocal(:,iNode) = [ r(j); r(i) ];
            postGridNodesGlobal(:,iNode) = mappingEvaluator(problem, elementIndex, [ r(j); r(i) ]);
            iNode = iNode + 1;
        end    
    end

    % create new cells
    nPostGridCells = (cuts+1)*(cuts+1);
    postGridCells=cell(nPostGridCells,1);
    iPostGridCell = 1;
    for i=1:cuts+1
        for j=1:cuts+1
            n0=i    + (cuts+2) * (j-1);
            n1=i+1  + (cuts+2) * (j-1);
            n2=i    + (cuts+2) * j;
            n3=i+1  + (cuts+2) * j;
            cellNodesGlobal = postGridNodesGlobal(:,[n0 n1 n2 n3]);
            cellNodesLocal = postGridNodesLocal(:,[n0 n1 n2 n3]);
            postGridCells{iPostGridCell} = { 2, cellNodesGlobal, elementIndex, cellNodesLocal }; 
            iPostGridCell = iPostGridCell + 1;
        end    
    end
    
end
