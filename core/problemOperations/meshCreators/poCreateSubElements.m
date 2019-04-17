function [ problem ] = poCreateSubElements( problem )

    if problem.dimension == 1

        nElements = numel(problem.elementTypeIndices);
        
        problem.subelementNodeIndices = problem.elementNodeIndices;
        problem.subelementTopologies = problem.elementTopologies;
        problem.subelementTypeIndices = problem.elementTypeIndices;

        problem.elementConnections = cell(1,nElements);
        for iElement = 1:nElements
            problem.elementConnections{1} = { { iElement 1 } };
        end
        
    else
        
        disp('ERROR! poCreateSubElements can only handle one dimension.');
    end

end

