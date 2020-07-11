
% load data
load('LShape_data.mat');
load('LShape_data_dynamic.mat');

% sampling time and frequency
deltaT = T/N;
f0 = 1/T;

% time and frequency vector
tDFT = (0:N-1)*deltaT;
fDFT = (0:N-1)*f0;

% total force vector
F = F0*f(tDFT);


%% dynamic analysis
%
%  !!!!!!!!!!!!!!!!
%   ______________
%  |              |
%  |              |
%  |       _______Q
%  |      |
%  |      |
%  |______|
%  ///////
%
% displacement = displacement at point Q
indexQ = [37:38];

% initialize dynamic problem
problem = poInitializeDynamicProblem(problem);

displacementX = zeros(1, problem.dynamics.nTimeSteps);
displacementY = zeros(1, problem.dynamics.nTimeSteps);







% ----------------------- DFT -----------------------
F_hat = fft(F, N, 2);
u_hat = zeros(size(F_hat));

for k = 0:N-1
    Omega_k = (2*pi/T) * k;
    if(k >= N/2)
       Omega_k = (2*pi/T) * (k - N);
    end
    Keff = K + 1i*Omega_k*D - (Omega_k.^2)*M;
    u_hat(:,k+1) = Keff \ F_hat(:,k+1);
end

uDFT = ifft(u_hat,N,2);
uDFT = real(uDFT);
% ---------------------------------------------------



uQx_DFT = uDFT(indexQ(1), :);
uQy_DFT = uDFT(indexQ(2), :);

%% save results
save('LShape_results_DFT.mat', 'uQx_DFT', 'uQy_DFT', 'uDFT', 'tDFT');
