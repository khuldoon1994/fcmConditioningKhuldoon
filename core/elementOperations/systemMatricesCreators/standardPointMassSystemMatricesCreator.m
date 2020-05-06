function [ Ke, Fe ] = standardPointMassSystemMatricesCreator(problem, elementIndex)

    % gather some information
    elementTypeIndex = problem.elementTypeIndices(elementIndex);
    nDof = eoGetNumberOfShapeFunctions(problem,elementIndex) * problem.dimension;
    
    % single dof "matrices"
    Ke = zeros(nDof,nDof);
    Fe = eoEvaluateTotalLoad(problem, elementIndex, []);
    
end