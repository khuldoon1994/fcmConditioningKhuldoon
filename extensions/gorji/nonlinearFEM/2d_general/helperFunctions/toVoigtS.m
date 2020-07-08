function [ vector ] = toVoigtS(tensor)
% convert tensor to vector

% todo:
% - dimensions
% - check if symmetric
% - strain or stress ????????????

% dimension = problem.dimension;
% 
% if dimension == 1
%     vector = tensor(1,1);
% elseif dimension == 2
%     vector = [ tensor(1,1); tensor(2,2); tensor(1,2) ];
%     
%     
% end

dim = size(tensor,1);

if(dim == 1)
    vector = tensor(1,1);
elseif(dim == 2)
    vector = [ tensor(1,1); tensor(2,2); tensor(1,2) ];
elseif(dim == 3)
    vector = [ tensor(1,1); tensor(2,2); tensor(3,3); tensor(1,2); tensor(2,3); tensor(1,3) ];
end




%% from femTask.m
% voigt notation
% toVoigt = @(tensor) [ tensor(1,1); tensor(2,2); tensor(1,2) ];
% fromVoigt = @(voigtVector) [ voigtVector(1) voigtVector(3); voigtVector(3) voigtVector(2) ];