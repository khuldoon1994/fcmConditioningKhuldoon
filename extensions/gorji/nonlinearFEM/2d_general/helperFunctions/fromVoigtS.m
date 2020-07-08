function [ tensor ] = fromVoigtS(vector)

n = length(vector);
dim2n = [1, 3, 6];
dim = find(dim2n == n);

if(dim == 1)
    tensor = vector(1);
elseif(dim == 2)
    tensor = [ vector(1) vector(3); ...
               vector(3) vector(2) ];
elseif(dim == 3)
    tensor = [ vector(1) vector(4) vector(6); ...
               vector(4) vector(2) vector(5); ...
               vector(6) vector(5) vector(3) ];
end




%% from femTask.m
% voigt notation
% toVoigt = @(tensor) [ tensor(1,1); tensor(2,2); tensor(1,2) ];
% fromVoigt = @(voigtVector) [ voigtVector(1) voigtVector(3); voigtVector(3) voigtVector(2) ];