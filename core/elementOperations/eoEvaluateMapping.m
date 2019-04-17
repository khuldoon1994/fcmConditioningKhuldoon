function [ X ] = eoEvaluateMapping( problem, elementIndex, r )

    elementTypeIndex = problem.elementTypeIndices(elementIndex);
    mappingEvaluator = problem.elementTypes{elementTypeIndex}.mappingEvaluator;
    X = mappingEvaluator(problem, elementIndex, r);

end

