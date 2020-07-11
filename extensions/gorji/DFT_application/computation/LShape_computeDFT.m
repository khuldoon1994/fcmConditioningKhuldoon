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
v_hat = zeros(size(F_hat));
a_hat = zeros(size(F_hat));

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
    
    % compute velocity and acceleration
    v_hat(:,k+1) = 1i*Omega_k*u_hat(:,k+1);
    a_hat(:,k+1) = 1i*Omega_k*v_hat(:,k+1);
end

uDFT = real(ifft(u_hat,N,2));
vDFT = real(ifft(v_hat,N,2));
aDFT = real(ifft(a_hat,N,2));
% ---------------------------------------------------


% displacement
uQx_DFT = uDFT(indexQ(1), :);
uQy_DFT = uDFT(indexQ(2), :);

% velocity
vQx_DFT = vDFT(indexQ(1), :);
vQy_DFT = vDFT(indexQ(2), :);

% acceleration
aQx_DFT = aDFT(indexQ(1), :);
aQy_DFT = aDFT(indexQ(2), :);


%% save results
save('computation/LShape_results_DFT.mat', 'tDFT', ...
     'uQx_DFT', 'uQy_DFT', 'uDFT', ...
     'vQx_DFT', 'vQy_DFT', 'vDFT', ...
     'aQx_DFT', 'aQy_DFT', 'aDFT');
