function [ strain] = linearStrain(problem, J)
% J = lambda

strain = J - 1;