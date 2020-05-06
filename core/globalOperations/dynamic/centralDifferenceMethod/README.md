<h1>Central Difference Method</h1>

go back to <a href="extensions/mahangorji/linearDynamics/">linear Dynamics</a>
<br>

<h4> cdmSolveLinearDynamics.m </h4>
This function computes the <b>displacements for every timestep</b>. The main
part of the code is shown in the following sequence. The element matrices and vectors
are computed with <i>goCreateElementMatrices</i>, assembled with <i>goAssembleSystem</i> and
finally the LSoE (linear systems of equations) is solved. If the <i>Mass Lumping Technique</i>
is defined, the system matrix is diagonal, which makes the solving
very easy and saves a lot of time.


<pre><code class="Matlab">
% main time integration for loop
% last iteration (n = n_samples) only necessary for U_dot_vec, U_ddot_vec
for n = 1:n_samples
    
    % calculate effective force vector
    [ F_eff ] = cdmEffectiveSystemForceVector(problem, M, D, K, F, U, U_old);
    
    % solve (for every timestep)
    tic();
    if(isdiag(K_eff))
        % if Mass Lumping
        U_new = F_eff./diag(K_eff);
    else
        %U_new = K_eff \ F_eff;
        U_new = K_eff_inv * F_eff;
    end
    cTime{n} = toc();
    cTimeTotal = cTimeTotal + cTime{n};
    
    % calculate velocities and accelerations
    [ U_dot, U_ddot ] = cdmVelocityAcceleration(problem, U_new, U, U_old);
    
    % attach to output
    U_vec{n+1} = U_new;
    U_dot_vec{n} = U_dot;
    U_ddot_vec{n} = U_ddot;
    
    % update
    U_old = U;
    U = U_new;
end
</code></pre>

<p style="float: left; font-size: 12pt; text-align: center; width: 100%; margin-right: 1%; margin-bottom: 0.5em;">
<img src="../../../../extensions/mahangorji/linearDynamics/Theory/scheme_CDM.png" width="100%">
Algorithm of the Central Difference Method: Calculate the next timestep from the  <b>last two</b> timesteps (since we solve a <b>second order</b> DGL).
Assume $`\underline{U}_{-1} = \underline{U}_{0} = 0`$ (system is in equilibrium for $`t \leq 0`$).
</p>


