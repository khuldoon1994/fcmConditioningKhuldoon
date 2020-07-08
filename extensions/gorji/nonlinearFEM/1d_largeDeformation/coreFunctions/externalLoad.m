function F = externalLoad(problem, allLe)

nDof = goNumberOfDof(problem);
U0 = zeros(nDof,1);
[ allUe ] = goDisassembleVector( U0, allLe );


% analysis
[ ~, allFe, ~ ] = goCreateNonlinearElementMatrices( problem, allUe );
F = goAssembleVector(allFe, allLe);


Fn = goCreateNodalLoadVector(problem);
F = F + Fn;

% % clampLeftSide
% F = F(2:end);