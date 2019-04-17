function [ Kp, Fp ] = goCreateAndAssemblePenaltyMatrices(problem)
%calcualtes the penalty stiffness matrices and penalty load vectors
%and assembles them

    % create temporary subelement location vectors
    nSubelements = numel(problem.subelementTypeIndices);
    allLse = cell(nSubelements,1);
    dofCounter=size(problem.nodes,2)*problem.dimension;
    for iSubelement=1:nSubelements
        [ allLse{iSubelement}, dofCounter ] = seoCreateLocationVector(problem,iSubelement,dofCounter);
    end
    
    % initialize return values
    nElements = numel(problem.elementTypeIndices);
    allLe = cell(nElements,1);
    % initialize penalty matrices and vectors
    allKp = cell(nElements,1);
    allFp = cell(nElements,1);

    for iElement = 1:nElements
      
        % add penalty constraints to matrices and vectors
        [ allKp{iElement}, allFp{iElement} ] = eoGetPenaltySystemMatrices(problem, iElement);
        % create location vector
        [ allLe{iElement} ] = eoGetLocationVector(problem, iElement, allLse);
        
    end
        
    Kp = goAssembleMatrix(allKp, allLe);
    Fp = goAssembleVector(allFp, allLe);
    
end