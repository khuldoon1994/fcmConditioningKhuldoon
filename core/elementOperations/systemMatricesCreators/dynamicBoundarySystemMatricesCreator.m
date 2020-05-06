function [ Me, Ke, Fe ] = dynamicBoundarySystemMatricesCreator(problem, elementIndex)

    [ Ke, Fe ] = boundarySystemMatricesCreator(problem, elementIndex);
    
    Me = zeros(size(Ke));
    
end