function [ E ] = greenLagrangeStrain(problem, F)
% F = deformation gradient

dimension = problem.dimension;
I = eye(dimension);


E = 0.5*(F'*F - I);