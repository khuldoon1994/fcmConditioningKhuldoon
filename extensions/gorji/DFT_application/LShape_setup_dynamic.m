% parameter
N = 400;
T = 10;
dT = 3;
Omega = 2*pi/T;

% sine load:
f_sine = @(t) sin(Omega*t);

% rect load:
f_rect = @(t) (mod(t,T) >= 0).*(mod(t,T) <= dT);

% triangle load:
f_triangle = @(t) (-4*t/T + 1).*(mod(t,T) >= 0).*(mod(t,T) < T/2) + ...
                  (+4*t/T - 3).*(mod(t,T) >= T/2).*(mod(t,T) < T);

f = f_rect;
% for later: F(t) = F0*f(t)

%% save data
save('LShape_data_dynamic.mat', 'f', 'T', 'N');
clear f_sine f_rect f_triangle