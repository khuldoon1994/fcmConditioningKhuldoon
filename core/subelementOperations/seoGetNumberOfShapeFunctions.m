function [ nShapes ] = seoGetNumberOfShapeFunctions(problem,subelementIndex)
  
    subelementTypeIndex = problem.subelementTypeIndices(subelementIndex);
    nShapes = problem.subelementTypes{subelementTypeIndex}.numberOfNodalShapes ...
        + problem.subelementTypes{subelementTypeIndex}.numberOfInternalShapes;
  
end