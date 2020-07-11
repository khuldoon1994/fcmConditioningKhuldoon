clear all
close all
clc


% load data
load('setup/LShape_data.mat');
load('setup/LShape_data_dynamic.mat');

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

% ----------------------- DFT -----------------------
F_hat = fft(F, N, 2);
u_hat = zeros(size(F_hat));

for k = 0:N-1
    Omega_k = (2*pi/T) * k;
    if(k >= N/2)
       Omega_k = (2*pi/T) * (k - N);
    end
    KEff = K + 1i*Omega_k*D - (Omega_k.^2)*M;
    FEff = F_hat(:,k+1);
    % add penalty constraints
    KEff = KEff + Kp;
    FEff = FEff + Fp;
    
    u_hat(:,k+1) = KEff \ FEff;
end

uDFT = ifft(u_hat,N,2);
uDFT = real(uDFT);
% ---------------------------------------------------



uQx_DFT = uDFT(indexQ(1), :);
uQy_DFT = uDFT(indexQ(2), :);

%% save results
save('computation/LShape_results_DFT.mat', 'uQx_DFT', 'uQy_DFT', 'uDFT', 'tDFT');
