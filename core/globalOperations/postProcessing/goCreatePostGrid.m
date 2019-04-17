function [ grid ] = goCreatePostGrid( problem, cuts )

    % get number of elements
    nElements = numel(problem.elementTypeIndices);
    
    % create post grid cells for each element
    postGridCells = cell(nElements,1);
    nPostGridCells=0;
    for iElement = 1:nElements
        elementTypeIndex = problem.elementTypeIndices(iElement);
        if problem.elementTypes{elementTypeIndex}.localDimension == problem.dimension
            postGridCellCreator = problem.elementTypes{elementTypeIndex}.postGridCellCreator;
            postGridCells{iElement} = postGridCellCreator(problem,iElement,cuts);
            nPostGridCells = nPostGridCells + numel(postGridCells{iElement});
        end
    end

    % concatenate all post grid cells
    grid = cell(nPostGridCells,1);
    cellCount = 0;
    for iElement = 1:nElements
        temp = postGridCells{iElement};
        for i=1:numel(temp)
            cellCount = cellCount + 1;
            grid{cellCount} = temp{i};
        end
    end

end

