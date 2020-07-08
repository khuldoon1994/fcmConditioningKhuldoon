function [ F ] = deformationGradient(problem, dUdX)

dimension = problem.dimension;
I = eye(dimension);


F = I + dUdX;