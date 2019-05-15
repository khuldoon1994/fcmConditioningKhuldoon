% SiHoFemLab - Step 1
% In SiHoFemLab, the problem definition is stored in a structure.
% In this script, the following problem will be defined:

%                        f(x)
%   /|---> ---> ---> ---> ---> ---> ---> --->
%   /|=======================================
%   /|          E,A,L

% A bar, characterized by its Youngs modulus E, area A and length L is
% loaded by a distributed force (one-dimensional "body-force").

%% clear variables, close figures
clear all; %#ok
close all;

%% setup problem
% Some things always need to be specified in the problem structure:
problem.name = 'elastic bar';
problem.dimension = 1;

% Here are some variables to make later changes easy:
E = 1.0;
A = 1.0;
L = 1.0;
f = @(x)( -sin(8*x) );

% Ok. Now we need a mesh, which will be part of the problem structure.
% For a mesh with two elements and three nodes we may choose
problem.nodes = [ 0, 0.5*L, L ];

% elements or 'quadrature supports'
problem.elementNodeIndices = { [1 2], [2 3] };
problem.elementTopologies = [ 1 1 ];
problem.elementTypeIndices = [ 1 1 ];

% So the nodes positions are stored in a vector with one column for each
% node and the elements are defined by their node indices, topologies and
% their types, which are stored in different cell arrays or vectors.
% All of the above elements have a topology index 1, a line, and a type 
% index 1, a type which we need to define:
problem.elementTypes = { poCreateElementTypeStandardLine1d(struct('gaussOrder', 6, 'youngsModulus', E, 'area', A )) };

% Now we have a cell array of element types with length one.
% In SiHoFemLab, the element types are there for mapping, integration,
% and everything else needed to create an element stiffnes matrix and load
% vector except the most important thing: the shape functions.
% They are defined by subelement types and subelements. We care about them
% in step 3 and just create them automatically here:
problem = poCreateSubElements( problem );
problem = poCreateElementConnections( problem );

% However, to be able to change the shape functions, we define the type
% manually here:
problem.subelementTypes = { poCreateSubelementType( 'LEGENDRE_LINE', struct('order', 5) ) };


% Next, we define the boundary conditions. The bar is loaded by a
% distributed force f(x) = -sin(8x) and clamped at the left end, which is
% enforced by the penalty method:
problem.loads = { f };
problem.penalties = { [0, 1e60] };

% The connections between the elements and the boundary conditions
problem.elementLoads = { 1, 1 };
problem.elementPenalties = { [], [] };
problem.elementFoundations = { [], [] };

% The connection between the nodes and the boundary conditions
problem.nodeLoads = { [],[],[] };
problem.nodePenalties = { 1,[],[] };


% That's it! The problem is ready to be solved. Run this script and explore
% the problem structure that will be in the workspace afterwards.
% You may also run poCheckProblem(problem) or goPlotMesh(problem,1) or
% proceed with step2.
