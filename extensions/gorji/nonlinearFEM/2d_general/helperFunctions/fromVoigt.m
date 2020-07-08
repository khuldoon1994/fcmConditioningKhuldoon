function [ tensor ] = fromVoigt(vector)

dim2 = length(vector);

if(dim2 == 1)
    tensor = vector(1);
elseif(dim2 == 4)
    tensor = [ vector(1) vector(2); ...
               vector(3) vector(4) ];
elseif(dim2 == 9)
    tensor = [ vector(1) vector(2) vector(3); ...
               vector(4) vector(5) vector(6); ...
               vector(7) vector(8) vector(9) ];
end




%% from femTask.m
% voigt notation
% toVoigt = @(tensor) [ tensor(1,1); tensor(2,2); tensor(1,2) ];
% fromVoigt = @(voigtVector) [ voigtVector(1) voigtVector(3); voigtVector(3) voigtVector(2) ];