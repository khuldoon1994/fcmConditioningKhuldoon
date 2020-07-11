% first run: 'LShape_setup.m'

% plot mesh and boundary conditions
goPlotMesh(problem,1);
goPlotLoads(problem,1,1);
goPlotPenalties(problem,1);
title('Problem setup');
axis equal;