% SiHoFemLab - Step 2
% Having created the problem structure in step1, its time for solving.

% We do one more check first. If poCheckProblem does not give any error
% messages and the figure created in goPlotProblem looks alright, everthing
% is ready for solving.
poCheckProblem(problem);

goPlotLoads(problem,1,0.1);
goPlotMesh(problem,1);
goPlotPenalties(problem,1);

% We start by creating cell arrays of element stiffness matrices, load 
% vectors and location vectors.
[ allKe, allFe, allLe ] = goCreateElementMatrices( problem );

% Then we assemble the global system of equations.
[ K, F ] = goAssembleSystem(allKe, allFe, allLe);

% We let MATLAB solve it.
U = K \ F;

% And disassemble the global solution vector to a cell array of element
% solution vectors.
[ allUe ] = goDisassembleVector( U, allLe );

% Then then we plot the solution.
goPlotSolution1d( problem, allUe, 10, 2 );

% Its as easy as that to solve any problem once you have created the 
% problem structure correctly. We will create a two-dimensional problem in
% step3, where also the meaning of subelements will become clear.