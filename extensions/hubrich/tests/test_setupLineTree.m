clear
clc
close

%%

physicalDomainTestFunction =@(x) x - 1.1;

% elementType.mappingEvaluator(problem, elementIndex, localPoints);
mappingEvaluator =@(problem, elementIndex, points) 0 + (1 + points) * (4 - 0)/2;

%%

quadratureType.depth = 4;

%%

elementType.quadratureType = quadratureType;
elementType.mappingEvaluator = mappingEvaluator;
elementType.physicalDomainTestFunction = physicalDomainTestFunction;

%%

problem.elementTypes = { elementType };
problem.elementTypeIndices = [1];
problem.elementNodeIndices = { [ 1 2 ] };

%%

lineTree = eoSetupLineTree( problem, 1 );

problem.elementQuadratures{1}.spaceTree = lineTree;

%%

plotLineTree(problem, 1)
