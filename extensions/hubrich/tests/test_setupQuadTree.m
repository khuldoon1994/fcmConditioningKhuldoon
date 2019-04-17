%%

clear
clc
close

%%

quadratureType.depth = 1;
physicalDomainTestFunction =@(X) -( (X(1,:) -100).^2 + (X(2,:)).^2-10^2);

%%
problem.name='Test: Setup quadtree';
problem.dimension = 2;

pA = 2;

problem.nodes=[0 50 100 0 50 100 0 50 100 ; 0 0 0 50 50 50 100 100 100];

elementType1 = poCreateElementType( 'STANDARD_QUAD_2D', { 'gaussOrder', pA+1, 'physics', 'PLANE_STRAIN', 'youngsModulus', 1, 'poissonRatio', 0.3 } );
elementType1.physicalDomainTestFunction = physicalDomainTestFunction;
elementType1.quadratureType = quadratureType;

problem.elementTypes = { elementType1 };

problem.elementNodeIndices = { [ 1 2 4 5 ], [ 2 3 5 6 ],[4 5 7 8], [5 6 8 9],[7 8],[8 9] };
problem.elementTopologies = [ 2 2 2 2 1 1];
problem.elementTypeIndices = [ 1 1 1 1 2 2];






% check and complete problem data structure
problem = poCheckProblem(problem);


%%
for i=1:length(problem.elementTypeIndices)
    problem.elementQuadratures{i}.spaceTree = eoSetupQuadTree(problem, i);
end
quadTree1 = problem.elementQuadratures{1}.spaceTree
quadTree2 = problem.elementQuadratures{2}.spaceTree

%

plotQuadTree( problem, 1 )

%% analysis
[ allKe, allFe, allLe ] = goCreateElementMatrices( problem );

[ K, F ] = goAssembleSystem(allKe, allFe, allLe);

U = K \ F;

[ allUe ] = goDisassembleVector( U, allLe );