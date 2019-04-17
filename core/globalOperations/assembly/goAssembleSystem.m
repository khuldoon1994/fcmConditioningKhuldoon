function [ K, F ] = goAssembleSystem( allKe, allFe, allLe )
%assembleGlobalSystem Assembles the global system.

    F = goAssembleVector(allFe, allLe);

    K = goAssembleMatrix(allKe, allLe);

end

