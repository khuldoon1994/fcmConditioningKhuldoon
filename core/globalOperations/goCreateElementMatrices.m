function [ allKe, allFe, allLe ] = goCreateElementMatrices(problem)
% goCreateElementMatrices Calcualtes the element stiffness matrices, load
% vectors and location vectors

    % create temporary subelement location vectors
    nSubelements = numel(problem.subelementTypeIndices);
    allLse = cell(nSubelements,1);
    dofCounter=size(problem.nodes,2)*problem.dimension;
    for iSubelement=1:nSubelements
        [ allLse{iSubelement}, dofCounter ] = seoCreateLocationVector(problem,iSubelement,dofCounter);
    end
    
    % initialize return values
    nElements = numel(problem.elementTypeIndices);
    allKe = cell(nElements,1);
    allFe = cell(nElements,1);
    allLe = cell(nElements,1);

    % loop over elements
    for iElement = 1:nElements
    
        % get element system matrices creator
        elementTypeIndex = problem.elementTypeIndices(iElement);
        systemMatricesCreator = problem.elementTypes{elementTypeIndex}.systemMatricesCreator;
      
        % create stiffness matrix and load vector
        [ allKe{iElement}, allFe{iElement} ] = systemMatricesCreator(problem, iElement);
  
        % create location vector
        [ allLe{iElement} ] = eoGetLocationVector(problem, iElement, allLse);

    end
        
end