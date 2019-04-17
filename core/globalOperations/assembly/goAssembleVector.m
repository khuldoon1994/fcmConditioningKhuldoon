function [ F ] = goAssembleVector( allFe, allLe )
%assembleGlobalLoadVector Assembles a global (dense) vector.

    % get number of elements
    nElements = numel(allLe);

    % check input arguments
    if numel(allFe) ~= nElements
       disp('ERROR! Number of element load vectors must be the same as number of element location vectors.');
    end

    % get number of degrees of freedom
    nDof = max(cellfun(@max,allLe));

    % initialize global load vector
    F=zeros(nDof,1);
    
    % loop over elements
    for i=1:nElements
        F(allLe{i}) = F(allLe{i}) + allFe{i};
    end

end

