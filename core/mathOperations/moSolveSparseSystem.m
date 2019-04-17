function [ x ] = moSolveSparseSystem( systemMatrix, rightHandSide )
% moSolveSparseSystem Solves a sparse linear system.

    warning('off','MATLAB:nearlySingularMatrix');
    
    x = systemMatrix \ rightHandSide;
    %[L,U] = lu(systemMatrix);
    %y = L\rightHandSide;
    %x = U\y;
    
    warning('on','MATLAB:nearlySingularMatrix');
end

