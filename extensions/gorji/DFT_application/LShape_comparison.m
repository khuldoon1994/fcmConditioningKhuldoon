
% load data
load('computation/LShape_results_DFT.mat');
load('computation/LShape_results_NM.mat');


%% Comparison
myPlot = @(t,u) plot([t, t(1)+T], [u, u(1)]);

figure();

h1a = myPlot(tNM,uQx_NM);
set(h1a, 'LineWidth', 1.2);
set(h1a, 'Color', 'r');
set(h1a, 'LineStyle', '-.');
% set(h1a, 'Marker', 'o');
hold on;
grid on;

h1b = myPlot(tNM,uQy_NM);
set(h1b, 'LineWidth', 1.4);
set(h1b, 'Color', 'r');
set(h1b, 'LineStyle', ':');
% set(h1b, 'Marker', 'o');


h2a = myPlot(tDFT,uQx_DFT);
set(h2a, 'LineWidth', 1.2);
set(h2a, 'Color', 'b');
set(h2a, 'LineStyle', '-.');
% set(h2a, 'Marker', 'x');

h2b = myPlot(tDFT,uQy_DFT);
set(h2b, 'LineWidth', 1.4);
set(h2b, 'Color', 'b');
set(h2b, 'LineStyle', ':');
% set(h2b, 'Marker', 'x');


xlabel('t [s]');
ylabel('u [m]');
legend('Newmark, u_x', ...
       'Newmark, u_y', ...
       'DFT, u_x', ...
       'DFT, u_y', ...
       'Location', 'SouthEast');
   
   
   