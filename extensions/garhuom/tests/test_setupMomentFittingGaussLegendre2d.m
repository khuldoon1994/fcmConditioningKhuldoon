
%%

clear
clc
close

%%
problem.name='Test: Setup moment fitting integration 2d';
problem.dimension = 2;

% geometry data
lengthXY = 1;
radius = 0.5; 
xc = 0.0; 
yc = 0.0;

levelSetFunction = @(X) -( (X(1,:) - xc).^2 + (X(2,:) - yc).^2 - radius^2 );

% integration data
alpha = 0.0;
pA = 5;
gaussOrder = 2*pA+1;
depth = 9;

%%
problem.nodes=[0.0 lengthXY 0.0 lengthXY ;
               0.0 0.0 lengthXY lengthXY];

% ADAPTIVE_GAUSS_LEGENDRE
% MOMENT_FITTING_GAUSS_LEGENDRE

elementType1 = poCreateFCMElementTypeQuad2d( struct( ...
    'levelSetFunction', levelSetFunction, ...
    'quadratureRule', 'MOMENT_FITTING_GAUSS_LEGENDRE',...
    'gaussOrder', gaussOrder,...
    'depth', depth,...
    'alphaFCM', alpha,...
'physics', 'PLANE_STRAIN', 'youngsModulus', 1, 'poissonRatio', 0.3));

problem.elementTypes = { elementType1 };

problem.elementNodeIndices = { [ 1 2 3 4 ] };
problem.elementTopologies = [ 2 ];
problem.elementTypeIndices = [ 1 ];

%%
problem.elementQuadratures = poSetupElementQuadratures(problem);
        
ng = length(problem.elementQuadratures{1}.weights)

%%
% detJ_c = (lengthXY*lengthXY)/4
detJ_c = det(eoEvaluateJacobian(problem,1,[0, 0]));

Aq = sum( problem.elementQuadratures{1}.weights )*detJ_c
Aex = lengthXY*lengthXY - (pi*radius^2)/4

e_r = abs( (Aq - Aex) / Aex )

%% plot adaptive gauss legendre 2d

plotAdaptiveGaussLegendre2d( problem, 1 )

points = problem.elementQuadratures{1}.points;
weights = problem.elementQuadratures{1}.weights;

% plot geometry
x=0:.01:radius;
y=sqrt(-(x-xc).^2 + radius^2);

hold on;
plot(x,y, 'linewidth', 2, 'color', 'blue')

%% test
if e_r>1e-6
   error('MomentFittingGaussLegendre2d: Integration check failed!');
else
   disp('MomentFittingGaussLegendre2d: Integration check passed.');
end