function R = internalLoad(problem, allLe, U)

[ allUe ] = goDisassembleVector( U, allLe );


% analysis
[ allRe, ~, ~ ] = goCreateNonlinearElementMatrices( problem, allUe );
R = goAssembleVector(allRe, allLe);

% % clampLeftSide
% R = R(2:end);