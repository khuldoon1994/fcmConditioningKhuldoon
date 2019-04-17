function [ nTotalDof, nNodalDof, nInternalDof ] = goNumberOfDof(problem)
    %calculate the number of degrees of freedoms
    %nTotalDof = nNodalDof + nInternalDof
    
    nNodalDof = size(problem.nodes,2)*problem.dimension;
    
    % create temporary subelement location vectors
    nSubelements = numel(problem.subelementTypeIndices);
    allLse = cell(nSubelements,1);
    dofCounter = nNodalDof;
    for iSubelement=1:nSubelements
        [ allLse{iSubelement}, dofCounter ] = seoCreateLocationVector(problem,iSubelement,dofCounter);
    end
    
    nTotalDof = dofCounter;
    nInternalDof = dofCounter - nNodalDof;
    
end