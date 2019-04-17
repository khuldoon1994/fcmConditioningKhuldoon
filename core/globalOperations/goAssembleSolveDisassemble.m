function [ Ue ] = goAssembleSolveDisassemble( Ke, Fe, Le )
% assembleSolveDisassemble Assembles the global system, solves it and
% disassembles the solution.

    if length(Fe) ~= length(Ke)
       disp('ERROR! Number of element stiffness matrices and element load vectors must be the same.'); 
    end

    if length(Fe) ~= length(Le)
       disp('ERROR! Number of element location vectors and element load vectors must be the same.'); 
    end

    F = goAssembleVector(Fe, Le);

    K = goAssembleMatrix(Ke, Le);

    U = K \ F;

    Ue = goDisassembleVector(U, Le);

end

