
% load data
load('computation/LShape_results_DFT.mat');
load('computation/LShape_results_NM.mat');


%% Comparison (acceleration)
myPlot = @(t,u) plot([t, t(end)+t(2)], [u, u(1)]);

figure();
subplot(2,1,1);

h1a = myPlot(tNM,aQx_NM);
set(h1a, 'LineWidth', 1.2);
set(h1a, 'Color', 'r');
set(h1a, 'LineStyle', '--');
% set(h1a, 'Marker', 'o');
hold on;
grid on;


h2a = myPlot(tDFT,aQx_DFT);
set(h2a, 'LineWidth', 1.2);
set(h2a, 'Color', 'b');
set(h2a, 'LineStyle', ':');
% set(h2a, 'Marker', 'x');

xlabel('t [s]');
ylabel('a_x [m/s^2]');
legend('Newmark', ...
       'DFT', ...
       'Location', 'NorthWest');



subplot(2,1,2);

h1b = myPlot(tNM,aQy_NM);
set(h1b, 'LineWidth', 1.2);
set(h1b, 'Color', 'r');
set(h1b, 'LineStyle', '--');
% set(h1b, 'Marker', 'o');
hold on;
grid on;

h2b = myPlot(tDFT,aQy_DFT);
set(h2b, 'LineWidth', 1.2);
set(h2b, 'Color', 'b');
set(h2b, 'LineStyle', ':');
% set(h2b, 'Marker', 'x');


xlabel('t [s]');
ylabel('a_y [m/s^2]');
legend('Newmark', ...
       'DFT', ...
       'Location', 'SouthWest');


% save figure
saveas(gcf,'results/results_LShape_compareAcc.jpg');


