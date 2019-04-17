function elementQuadratures = poSetupElementQuadratures( problem )
% poSetupElementQuadratures Computes the quadrature points for all elements
% This function is needed, e.g. in the case of FCM analyses, where the 
% quadrature poiunts should only by computed once.

nElements = length(problem.elementTypeIndices);

elementQuadratures = cell(nElements,1);

for iElement=1:nElements
    elementTypeIndex = problem.elementTypeIndices(iElement);
    elementType = problem.elementTypes{elementTypeIndex};

    % get function handle
    setupQuadraturePoints = moParseFunctionHandle('setupQuadraturePoints', ...
        elementType.quadraturePointGetterData,@()[],...
        ['quadrature point getter data for element type',elementType.name]);

    % create quadrature points
    elementQuadratures{iElement} = setupQuadraturePoints(problem, iElement);
end

end

