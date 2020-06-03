function [ FEff ] = newmarkEffectiveSystemForceVector(problem, M, D, K, F, u, uDot, uDdot)
    %calculate effective force vector for the Newmark Integration Method
    % u         =       u(n)
    % uDot      =       d/dt u(n)
    % uDdot     =       d^2/dt^2 u(n)
    
    
    % parameter = {deltaT, alpha, delta}
    parameter = problem.dynamics.parameter;
    deltaT = parameter{1};
    alpha = parameter{2};
    delta = parameter{3};
    
    % integration constants
    a0 = 1/(alpha*deltaT^2);
    a1 = delta/(alpha*deltaT);
    a2 = 1/(alpha*deltaT);
    a3 = 1/(2*alpha)-1;
    a4 = delta/alpha-1;
    a5 = deltaT/2*(delta/alpha-2);
    a6 = deltaT*(1-delta);
    a7 = delta*deltaT;
    
    % effective force vector
    FEff = F + M*(a0*u+a2*uDot+a3*uDdot) + D*(a1*u+a4*uDot+a5*uDdot);
    
end