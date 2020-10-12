
%%

clear
clc
close

%%
size = 2;
radius = 0.5; 
xc = 0.0; 
yc = 0.0;

quadraturePointGetterData.levelSetFunction = @(X) -( (X(1,:) - xc).^2 + (X(2,:) - yc).^2 - radius^2 );

pA = 3;
gaussOrder = 2*pA+1;
quadraturePointGetterData.depth = 7;
quadraturePointGetterData.gaussOrder = gaussOrder;
quadraturePointGetterData.alphaFCM = 0;

%%
problem.name='Test: Setup moment fitting integration 2d';
problem.dimension = 2;

problem.nodes=[0.0 size 0.0 size ;
               0.0 0.0 size size];

elementType1 = poCreateElementType( 'STANDARD_QUAD_2D', struct( 'gaussOrder', gaussOrder, 'physics', 'PLANE_STRAIN', 'youngsModulus', 1, 'poissonRatio', 0.3 ) );
elementType1.quadraturePointGetterData = quadraturePointGetterData;

problem.elementTypes = { elementType1 };

problem.elementNodeIndices = { [ 1 2 3 4 ] };
problem.elementTopologies = [ 2 ];
problem.elementTypeIndices = [ 1 ];

%%

%problem.elementQuadratures = {eoSetupAdaptiveGaussLegendre2d( problem, 1 )};
problem.elementQuadratures = {setupMomentFittingGaussLegendre2d( problem, 1 )};

ng = length(problem.elementQuadratures{1}.weights)

%%

Aq = sum( problem.elementQuadratures{1}.weights )
Aex = size*size - (pi*radius^2)/4

e_r = abs( (Aq - Aex) / Aex )

%% plot adaptive gauss legendre 2d

plotAdaptiveGaussLegendre2d( problem, 1 )

points = problem.elementQuadratures{1}.points;
weights = (problem.elementQuadratures{1}.weights);

%% test
if e_r>1e-6
   error('MomentFittingGaussLegendre2d: Integration check failed!');
else
   disp('MomentFittingGaussLegendre2d: Integration check passed.');
end
