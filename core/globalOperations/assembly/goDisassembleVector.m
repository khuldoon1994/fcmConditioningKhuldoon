function [ allUe ] = goDisassembleVector( U, allLe )
% disassembleGlobalSolutionVector Disassembles a global (dense) vector.

% get number of elements
nElements = numel(allLe);

% initialize cell array
allUe = cell(nElements,1);

% disassemble global solution vector
for i=1:nElements
    allUe{i} = U(allLe{i});
end

end

