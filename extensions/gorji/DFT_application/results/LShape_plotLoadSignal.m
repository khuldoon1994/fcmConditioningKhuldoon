
% load data
load('setup/LShape_data_dynamic.mat');

%% plot load signal over time
t = linspace(0,T,N+1);
t(end) = [];
tExt = [t-10,t,t+10];


figure();

h1 = plot(tExt,f(tExt));
set(h1,'LineWidth',1.2);
set(h1,'color','k');

hold on
grid on


ymin = -0.25;
ymax = 1.25;
yArr = 0.19;
face = [1 2 3 4];
vert = [0.0, ymin; T, ymin; T, ymax; 0.0, ymax];
patch('Faces',face,'Vertices',vert,'FaceColor',0.5*[1 1 1],'FaceAlpha',0.3,'EdgeColor','none');
text(0.49, 0.05, 'T', 'FontSize', 14, 'units', 'normalized');
annotation('textarrow',[0.52 0.64],[yArr yArr]);
annotation('textarrow',[0.52 0.4], [yArr yArr]);
plot(0.0*[1, 1], [ymin ymax], 'k:', 'LineWidth', 1.2);
plot(T*[1, 1], [ymin ymax], 'k:', 'LineWidth', 1.2);


ylim([ymin ymax]);
xlabel('t [s]');
ylabel('f(t)');



% save figure
saveas(gcf,'results/results_LShape_loadSignal.jpg');

