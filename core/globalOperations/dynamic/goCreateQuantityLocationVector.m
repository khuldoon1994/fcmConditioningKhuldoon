function [ Lq ] = goCreateQuantityLocationVector(problem, quantityLocationVector)
%refer the quantityLocationVector to Lq
%Quantity can be Displacement, Velocity or Acceleration
    
    % if its an array
    if(isnumeric(quantityLocationVector))
        Lq = quantityLocationVector;
    % if its a string / char
    elseif(isstring(quantityLocationVector) || ischar(quantityLocationVector))
        % convert string to char
        quantityLocationVector = char(quantityLocationVector);
        
        dimension = problem.dimension;
        [ nTotalDof, nNodalDof, nInternalDof ] = goNumberOfDof(problem);
        switch quantityLocationVector
            % general
            case 'all'
                Lq = 1:nTotalDof;
            case 'nodes'
                Lq = 1:nNodalDof;
            case 'internal'
                Lq = nNodalDof + (1:nInternalDof);
            % only specific components (X, Y or Z) of a quantity
            case 'nodesX'
                Lq = 1:dimension:nNodalDof;
            case 'nodesY'
                if(problem.dimension < 2)
                    error('nodesY only makes sense for two- or three-dimensional problems');
                end
                Lq = 2:dimension:nNodalDof;
            case 'nodesZ'
                if(problem.dimension < 3)
                    error('nodesZ only makes sense for three-dimensional problems');
                end
                Lq = 3:dimension:nNodalDof;
            % faces, edges, etc.
            otherwise
                error('unknown string. for example, set quantityLocationVector to "all"');
        end
    % if its neither an array or a string / char
    else
        error('quantityLocationVector has a wrong data type');
    end

end