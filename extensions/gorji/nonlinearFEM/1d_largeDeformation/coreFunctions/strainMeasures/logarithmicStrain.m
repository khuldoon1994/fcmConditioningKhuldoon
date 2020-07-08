function [ strain] = logarithmicStrain(problem, J)
% J = lambda

strain = log(J);