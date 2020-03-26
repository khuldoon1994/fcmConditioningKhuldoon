function goPlotDisplacementArrows2d ( problem, displacement, fig )
% goPlotSolution1d Plots the solution for a one dimensional problem

if problem.dimension~=2
   disp('Error! This function can only handle two-dimensional problems.');
   return;
end

figure(fig)

pos = problem.nodes
nNodes = size(problem.nodes, 2)
disp = reshape(displacement, 2, nNodes)

quiver(pos(1,:), pos(2,:), disp(1,:), disp(2,:), ...
        'Color','blue','LineWidth',1,'MaxHeadSize',1);
        