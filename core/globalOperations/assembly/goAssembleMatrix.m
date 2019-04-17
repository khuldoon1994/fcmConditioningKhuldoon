function [ K ] = goAssembleMatrix( allKe, allLe )
%assembleGlobalStiffnessMatrix Assembles the global (sparse) system matrix.

% check input arguments
if length(allLe) ~= length(allKe)
   disp('ERROR! Number of element stiffness matrices and element location vectors must be the same.'); 
end

% get number of elements
nElements = length(allLe);

% total number of values to be assembled
nValues = sum(cellfun(@length,allKe));

% temporary vectors memory
values = zeros(nValues,1);
rows = zeros(nValues,1);
cols = zeros(nValues,1);

% loop over elements
offset = 1;
for i=1:nElements
    % create local copy (Ke{i} cannot be indexed directly)
    Ktemp = allKe{i};
    % get number of dofs for this element
    eDof = length(allLe{i});
    % assemble row by row
    for row=1:eDof
       values(offset:offset+eDof-1) = Ktemp(row,:);
       rows(offset:offset+eDof-1) = allLe{i}(row);
       cols(offset:offset+eDof-1) = allLe{i};
       offset = offset + eDof;
    end
end

% create sparse matric from vectors of rows, columns and values
K=sparse(rows,cols,values);

end

