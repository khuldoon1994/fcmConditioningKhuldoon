function [ problem ] = poCreateElementConnections( problem )
% poCreateElementConnections Creates connections between elements and
% subelements. A subelement is connected to an element if all of its node
% indices are contained in the element's node indices or other way round.

    nSubelements = numel(problem.subelementTypeIndices);
    nElements = numel(problem.elementTypeIndices);

    problem.elementConnections = cell(nElements,1);
    
    for iElement = 1:nElements
        
        elementTopology = problem.elementTopologies(iElement);
        elementNodeIndices = problem.elementNodeIndices{iElement};

        currentElementConnections = {};

        % find all subelements which are part of this element
        for iSubelement = 1:nSubelements

            subelementTopology = problem.subelementTopologies(iSubelement);
            subelementNodeIndices = problem.subelementNodeIndices{iSubelement};
           
            if moContainsAll(elementNodeIndices, subelementNodeIndices) || moContainsAll(subelementNodeIndices, elementNodeIndices)
                       
                Q = moCreateTransformation(elementTopology, elementNodeIndices, subelementTopology, subelementNodeIndices);
                
                newConnection = { iSubelement; Q };
                       
                currentElementConnections{end+1} = newConnection; %#ok
            end

        end
        
        if numel(currentElementConnections)<1 
           disp('ERROR! Did not find a subelement for element ',num2str(iElement),'.'); 
        end
        
        problem.elementConnections{iElement}=currentElementConnections;
    end

end

