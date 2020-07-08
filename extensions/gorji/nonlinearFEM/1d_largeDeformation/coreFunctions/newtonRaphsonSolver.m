function U = newtonRaphsonSolver(R, F, U0, options)
% solving a nonlinear system of equations: R(U) = F

tol = options.tol;
iter_max = options.iter_max;
stepSize = options.stepSize;

iter = 0;
n = length(U0);


U = U0;
KT = zeros(n,n);
residual = R(U0) - F;

while( (norm(residual) > tol) && (iter < iter_max) )
    % compute tangent stiffness matrix
    for k = 1:n
        ek = zeros(n,1);
        ek(k) = 1;
        hk = stepSize;
        
        % discrete Newton-Raphson Method
        % see P. Wriggers, Nonlinear Finite Element Methods
        % Equations (5.3) and (5.4)
        KT(:,k) = (R(U + hk*ek) - R(U))/hk;
    end
    % compute residual
    r = F - R(U);
    
    
    % solve linear system of equations
    dU = KT\r;
    
    % update solution
    U = U + dU;
    
    % compute residual
    residual = R(U) - F;
end




% % unclampLeftSide
% U = [0; U];
