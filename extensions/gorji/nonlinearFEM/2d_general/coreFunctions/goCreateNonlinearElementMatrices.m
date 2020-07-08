function [ allKTe, allRe, allLe ] = goCreateNonlinearElementMatrices(problem, allUe)
% goCreateElementMatrices Calcualtes the element stiffness matrices, load
% vectors and location vectors

    % create temporary subelement location vectors
    nSubelements = numel(problem.subelementTypeIndices);
    allLse = cell(nSubelements, 1);
    dofCounter = size(problem.nodes, 2)*problem.dimension;
    for iSubelement=1:nSubelements
        [ allLse{iSubelement}, dofCounter ] = seoCreateLocationVector(problem, iSubelement, dofCounter);
    end
    
    % initialize return values
    nElements = numel(problem.elementTypeIndices);
    allKTe = cell(nElements, 1);
    allRe = cell(nElements, 1);
    allLe = cell(nElements, 1);

    % loop over elements
    for iElement = 1:nElements
        
        Ue = allUe{iElement};
    
        % get element system matrices creator
        elementTypeIndex = problem.elementTypeIndices(iElement);
        nonlinearSystemMatricesCreator = problem.elementTypes{elementTypeIndex}.nonlinearSystemMatricesCreator;
        
        % create stiffness matrix and load vector
        [ allKTe{iElement}, allRe{iElement} ] = nonlinearSystemMatricesCreator(problem, iElement, Ue);
  
        % create location vector
        [ allLe{iElement} ] = eoGetLocationVector(problem, iElement, allLse);

    end
        
end