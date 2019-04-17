function [ u0Ddot ] = goComputeInitialAcceleration(problem, M, D, K, F, u0, u0Dot)
    %calculate the initial acceleration
    % u0        =       u(0)
    % u0Dot     =       d/dt u(0)
    % u0Ddot    =       d^2/dt^2 u(0)
    
    u0Ddot = M\(F - D*u0Dot - K*u0);
end