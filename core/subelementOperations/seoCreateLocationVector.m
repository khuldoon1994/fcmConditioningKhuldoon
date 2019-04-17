function [ Lse, dofCounter ] = seoCreateLocationVector(problem, subelementIndex, dofCounter)
%getLocationVector Create the location vector for the current element

    subelementTypeIndex = problem.subelementTypeIndices(subelementIndex);
    dimension = problem.dimension;
    
    % number of nodal shape functions in this subelement
    nNodalShapes = problem.subelementTypes{subelementTypeIndex}.numberOfNodalShapes;
    nNodalDof = dimension * nNodalShapes;
    
    % number of internal shape functions in this subelement
    nInternalShapes = problem.subelementTypes{subelementTypeIndex}.numberOfInternalShapes;
    nInternalDof = dimension * nInternalShapes;
    
    % total number of degrees of freedom in this element
    nDof = nInternalDof + nNodalDof;
       
    % initialize location vector
    Lse = zeros(nDof,1);
    
    % insert nodal dofs acc. to node indices
    if nNodalDof > 0
        for iDimension = 1:dimension
            Lse(iDimension:dimension:nNodalDof) = iDimension ...
                + (problem.subelementNodeIndices{subelementIndex}-1)*dimension;
        end
    end
    
    % get index range for internal dofs
    firstInternalDof = dofCounter + 1;
    lastInternalDof = dofCounter + nInternalDof;
    
    % add internal dofs if there are any
    if firstInternalDof<=lastInternalDof
      Lse(nNodalDof+1:nNodalDof+nInternalDof) = firstInternalDof:lastInternalDof;
    end
    
    dofCounter = dofCounter + nInternalDof;
end

