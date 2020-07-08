function [ strain] = almansiStrain(problem, J)
% J = lambda

strain = 0.5*(1 - 1/(J^2));