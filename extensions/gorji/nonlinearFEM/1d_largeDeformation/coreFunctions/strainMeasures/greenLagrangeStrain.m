function [ strain] = greenLagrangeStrain(problem, J)
% J = lambda

strain = 0.5*(J^2 - 1);