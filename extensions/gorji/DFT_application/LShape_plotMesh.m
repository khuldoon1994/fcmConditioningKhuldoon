% first run: 'LShape_setup.m'

scaleLoad = 5e-4;

% plot mesh and boundary conditions
goPlotMesh(problem,1);
goPlotLoads(problem,1,scaleLoad);
goPlotPenalties(problem,1);
title('Problem setup');
axis equal;