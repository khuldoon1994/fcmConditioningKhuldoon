%                       f(x)
%   /|---> ---> ---> ---> ---> ---> ---> --->
%   /|=======================================
%   /|          E,A,rho,kappa,L
%
% A bar, characterized by its Youngs modulus E, area A,
% mass density rho, damping coefficient kappa and length L
% is loaded by a distributed force (one-dimensional "body-force").

%% clear variables, close figures
% clear all;
% close all;
% clc;
warning('off', 'MATLAB:nearlySingularMatrix'); % get with [a, MSGID] = lastwarn();

%% problem definition
problem.name = 'dynamicBar1D (Central Difference Method)';
problem.dimension = 1;

% % volume load
f = @(x) 0; 

% static parameters
E = 20e9;                  %(paper: 70e9)  
A = 4e-04;                 %(paper: 0.0006)  
L = 3;                     %(paper: 20.0) 

% E = 70e9;                  % paper  
% A = 0.0006;                % paper
% L = 20.0;                  % paper

% decide whether damped or undamped case should be observed 
loop = true; 
while loop
   opt_d = input ('Choose between damped (1) or undamped (0)?'); 
   
   if opt_d == 1 
      alpha = 30;   % initially 10 
      loop = false; 
   elseif opt_d == 0
      alpha = 0.0;
      loop = false; 
   
   else 
      disp('Unvalid input. Please repeat')
   end 
end 
loop = true; 

rho = 2700;                % mass density (paper: 2700)  
kappa = rho * alpha;

% spatial discetization
p = 3;       
n = 5;       % initial value = 100    

%% temporal discretization
% % long time for low n values
% tStart = 0;
% tStop = 20;                
% nTimeSteps = 50000;  

% tStart = 0; 
% tStop = 4;                
% nTimeSteps = 5000;  

% tStart = 0;                   % paper  
% tStop = 0.004;                % paper  
% nTimeSteps = 800;             % paper   

% short time to check whether working or not 
tStart = 0;
tStop = 0.05;                
nTimeSteps = 500;         


% special parameters needed for proposed method & NB method 
p_nb = 0.54;              % time step coefficient 
eta = 1.5;                 

%% chosing a method 

loop = true; 
tic
while loop 
    opt = input ('Choose a method: cdm (0), nb (1), proposed (2), all (3)'); 
    
    if opt == 0 
        cdm(f, E, A, L, rho, alpha, kappa, p, n, tStart, tStop, nTimeSteps, opt)
        loop = false; 
    elseif opt == 1 
        nb(f, E, A, L, rho, alpha, kappa, p, n, tStart, tStop, nTimeSteps, p_nb, eta, opt)
        loop = false; 
    elseif opt == 2
        proposed(f, E, A, L, rho, alpha, kappa, p, n, tStart, tStop, nTimeSteps, p_nb, eta, opt)
        loop = false;
    elseif opt == 3 
        cdm(f, E, A, L, rho, alpha, kappa, p, n, tStart, tStop, nTimeSteps, opt)
        hold on
        nb(f, E, A, L, rho, alpha, kappa, p, n, tStart, tStop, nTimeSteps, p_nb, eta, opt )
        proposed(f, E, A, L, rho, alpha, kappa, p, n, tStart, tStop, nTimeSteps, p_nb, eta, opt )
        loop = false;
    else 
        disp('Unvalid input. Repeat')
    end 
end 
loop = true;
toc

%% without user interaction 
% opt = 'all'; 
% 
% if strcmp(opt, 'cdm') | (opt == 0)
%      cdm(f, E, A, L, rho, alpha, kappa, p, n, tStart, tStop, nTimeSteps, opt)
% 
% elseif strcmp(opt, 'nb') | (opt == 1)
%      nb(f, E, A, L, rho, alpha, kappa, p, n, tStart, tStop, nTimeSteps, p_nb, eta, opt)
%     
% elseif strcmp(opt, 'proposed') | (opt == 2)
%      proposed(f, E, A, L, rho, alpha, kappa, p, n, tStart, tStop, nTimeSteps, p_nb, eta, opt)
% 
% elseif strcmp(opt, 'all') | (opt == 3) 
%      cdm(f, E, A, L, rho, alpha, kappa, p, n, tStart, tStop, nTimeSteps, opt)
%      hold on
%      nb(f, E, A, L, rho, alpha, kappa, p, n, tStart, tStop, nTimeSteps, p_nb, eta, opt )
%      proposed(f, E, A, L, rho, alpha, kappa, p, n, tStart, tStop, nTimeSteps, p_nb, eta, opt )
%     
% else 
%     s = sprintf('\n WARNING');
%     s = [s,sprintf('\nUse different option for method selection. Options are:')];
%     s = [s,sprintf('\n cdm (0)')];
%     s = [s,sprintf('\n nb  (1)')];
%     s = [s,sprintf('\n proposed (2)')]; 
%     s = [s,sprintf('\n all (3)')];   
%     disp(s);





