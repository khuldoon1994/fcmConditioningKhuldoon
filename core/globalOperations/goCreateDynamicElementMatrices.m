function [ allMe, allDe, allKe, allFe, allLe ] = goCreateDynamicElementMatrices(problem)
%createElementMatrices calcualtes the element mass matrices, damping 
%matrices, stiffness matrices, load vectors and location vectors
    
    % create temporary subelement location vectors
    nSubelements = numel(problem.subelementTypeIndices);
    allLse = cell(nSubelements,1);
    dofCounter=size(problem.nodes,2)*problem.dimension;
    for iSubelement=1:nSubelements
        [ allLse{iSubelement}, dofCounter ] = seoCreateLocationVector(problem,iSubelement,dofCounter);
    end
    
    % initialize return values
    nElements = numel(problem.elementTypeIndices);
    allMe = cell(nElements,1);
    allDe = cell(nElements,1);
    allKe = cell(nElements,1);
    allFe = cell(nElements,1);
    allLe = cell(nElements,1);
    
    % get Rayleigh damping coefficients
    massCoeff = problem.dynamics.massCoeff;
    stiffCoeff = problem.dynamics.stiffCoeff;
    
    % loop over elements
    for iElement = 1:nElements
        
        % get element system matrices creator
        elementTypeIndex = problem.elementTypeIndices(iElement);
        systemMatricesCreator = problem.elementTypes{elementTypeIndex}.systemMatricesCreator;
        
        % create mass matrix, stiffness matrix and load vector
        [ allMe{iElement}, allKe{iElement}, allFe{iElement} ] = systemMatricesCreator(problem, iElement);
        
        % apply Rayleigh damping
        allDe{iElement} = massCoeff*allMe{iElement} + stiffCoeff*allKe{iElement};
        
        % create location vector
        [ allLe{iElement} ] = eoGetLocationVector(problem, iElement, allLse);
        
    end
end