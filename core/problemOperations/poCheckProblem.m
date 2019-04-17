function [ problem ] = poCheckProblem(problem)

%% general
if strcmp(problem.name,'') 
   disp('ERROR! Problem name must not be empty.'); 
end

if problem.dimension < 1 || problem.dimension > 3
   disp('ERROR! Problem dimension must be one of 1,2,3.'); 
end

problem.nElementTypes = numel(problem.elementTypes);
if problem.nElementTypes<1
   disp('ERROR! Problem elementTypes must be a cell array with at least one entry.'); 
end

problem.nSubelementTypes = numel(problem.subelementTypes);
if problem.nSubelementTypes<1
   disp('ERROR! Problem subelementTypes must be a cell array with at least one entry.'); 
end

%% nodes
problem.nNodes = size(problem.nodes,2);
if(size(problem.nodes,1)~=problem.dimension)
  disp('ERROR! Problem nodes must have one row for each dimension.');
end

% check node boundary conditions
if numel(problem.nodeLoads) ~= problem.nNodes
   disp('ERROR! Problem nodeLoads must be a cell array with one entry for each node.'); 
end

if numel(problem.nodePenalties) ~= problem.nNodes
   disp('ERROR! Problem nodePenalties must be a cell array with one entry for each node.'); 
end

%% elements
problem.nElements = numel(problem.elementTypeIndices);
if numel(problem.elementNodeIndices) ~= problem.nElements
   disp('ERROR! Problem elementNodeIndices must be a cell array with one entry for each element.'); 
end

% check element boundary conditions
if numel(problem.elementLoads) ~= problem.nElements
   disp('ERROR! Problem elementLoads must be a cell array with one entry for each element.'); 
end
if numel(problem.elementPenalties) ~= problem.nElements
   disp('ERROR! Problem elementPenalties must be a cell array with one entry for each element.'); 
end

%% subelements
problem.nSubelements = numel(problem.subelementTypeIndices);
if numel(problem.subelementNodeIndices) ~= problem.nSubelements
   disp('ERROR! Problem subelementNodeIndices must be a cell array with one entry for each subelement.'); 
end

%% connections
% check connections between elements and subelements
if numel(problem.elementConnections) ~= problem.nElements
   disp('ERROR! Problem elementConnections must be a cell array with one entry for each element.'); 
end

end