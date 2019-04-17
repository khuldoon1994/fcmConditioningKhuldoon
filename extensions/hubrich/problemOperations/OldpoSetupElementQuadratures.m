function problem = OldpoSetupElementQuadratures( problem )
%poSetupElementQuadratures Summary of this function goes here
%   Detailed explanation goes here

nElements = length(problem.elementTypeIndices);

problem.elementQuadratures = cell(nElements,1);

for iElement=1:nElements
    elementTypeIndex = problem.elementTypeIndices(iElement);
    elementType = problem.elementTypes{elementTypeIndex};
    setupQuadraturePoints = problem.elementTypes{1,elementTypeIndex}.quadraturePointGetterData.setupQuadraturePoints;
    problem.elementQuadratures{1,iElement} = setupQuadraturePoints(problem, iElement);
end

end

