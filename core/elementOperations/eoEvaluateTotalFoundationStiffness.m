function [ totalFoundationStiffness ] = eoEvaluateTotalFoundationStiffness( problem, elementIndex, r )
% [ totalFoundationStiffness ] = calculateLoad( problem, elementIndex, r )
% Caculates the foundation stiffnes for an element.

    % initialize return value
    totalFoundationStiffness = 0;

    % get load indices for this element
    foundationIndices = problem.elementFoundations{elementIndex};
        
    % sum up total load
    nFoundations = length(foundationIndices);
    for iFoundation = 1:nFoundations
        
        % get a copy of the current load
        foundation = problem.foundations{foundationIndices(iFoundation)};
        
        % add value to total foundation stiffness
        if isnumeric(foundation)
            % foundation stiffnes is constant
            totalFoundationStiffness = totalFoundationStiffness + foundation;    
        else
            % foundation stiffness is a function of the global position
            X = eoEvaluateMapping(problem,elementIndex,r);
            totalFoundationStiffness = totalFoundationStiffness + foundation(X);
        end
        
    end

end

