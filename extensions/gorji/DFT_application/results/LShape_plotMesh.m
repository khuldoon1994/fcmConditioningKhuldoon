
% load data
load('setup/LShape_data.mat');

%% plot mesh
scaleLoad = 5e-4;

% plot mesh and boundary conditions
goPlotMesh(problem,1);

% save figure
saveas(gcf,'results/results_LShape_mesh.jpg');

goPlotLoads(problem,1,scaleLoad);
goPlotPenalties(problem,1);
title('Problem setup');
axis equal;