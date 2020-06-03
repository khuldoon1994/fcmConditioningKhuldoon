function [ Me, Ke, Fe ] = dynamicBoundarySystemMatricesCreator(problem, elementIndex)

    % evaluate standard system matrices creator
    [ Ke, Fe ] = boundarySystemMatricesCreator(problem, elementIndex);
    
    % element mass matrix
    Me = zeros(size(Ke));
    
end