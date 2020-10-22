
%% clear variables, close figures
clear all %#ok
clc
close all

format longE;

%% problem definition
problem.name='FCM Test 2D 4 Elements conditioning';
problem.dimension = 2;

%% parameters
% polynomial degree
p= 1;

% integration depth
n=5;

% material
%digits(20);
%E = vpa(1.0);
E = 1.0;
mu = 0.3;

sizeGeom = 1.0;
alpha = 0.0; %1.0e-10;
load = 450;

%level set
R = 0;
X0 = 100;
Y0 = 0;
levelSetFunction =  @(X) -( (X(1,:) -X0).^2 + (X(2,:) -Y0 ).^2 - R.^2);

%% Start analysis
% cell types 
elementType1 = poCreateFCMElementTypeQuad2d( struct( ...
    'levelSetFunction', levelSetFunction, ...
    'quadratureRule', 'ADAPTIVE_GAUSS_LEGENDRE',...
    'gaussOrder', 2*p,...
    'depth', n,...
    'alphaFCM', alpha,...
'physics', 'PLANE_STRESS', 'youngsModulus', E, 'poissonRatio', mu));

elementType2 = poCreateFCMElementTypeLine2d( struct( ...
    'levelSetFunction', levelSetFunction, ...
    'quadratureRule', 'ADAPTIVE_GAUSS_LEGENDRE',...
    'gaussOrder', 2*p,...
    'depth', n,...
    'alphaFCM', alpha,...
'physics', 'PLANE_STRESS', 'youngsModulus', E, 'poissonRatio', mu));

problem.elementTypes = { elementType1, elementType2 };

% mesh data
problem.nodes = [ 0.0, sizeGeom ,0, sizeGeom;
                  0.0, 0.0, sizeGeom, sizeGeom ];

% 
problem.elementTopologies = [ 2 1 1 1];
problem.elementTypeIndices = [ 1 2 2 2];
problem.elementNodeIndices = {
    [ 1 2 3 4 ]
    [1 2] % penalty constraint
    [3 4] %load
    [2 4] % penalty constraint              
};

% subelement 
subelementType1 = poCreateSubelementType( 'LEGENDRE_QUAD', struct( 'order', p ) );
subelementType2 = poCreateSubelementType( 'LEGENDRE_EDGE', struct( 'order', p ) );
problem.subelementTypes = { subelementType1, subelementType2 };

% high order
problem.subelementTopologies = [ 2, 1, 1, 1, 1 ];
problem.subelementTypeIndices = [ 1, 2, 2, 2, 2];
problem.subelementNodeIndices = {
    [ 1 2 3 4 ]
    [ 1 2 ] % penalty constraint
    [ 3 4 ] %load
    [ 1 3 ]
    [ 2 4 ] % penalty constraint
};

problem = poCreateElementConnections( problem );

% boundary conditions
problem.loads = { [0 ; 450] };
penalty1 = [0, 0; 0, 1e20] ;
penalty2 =  [ 0, 1e20; 0, 0] ;
penalty3 =  [ 0, 1e20; 0, 1e20] ;
problem.penalties = { penalty1, penalty2, penalty3};
problem.foundations = { [] };

problem.elementLoads = {[],[],1,[]};
problem.elementPenalties = {[],1,[],2};
problem.elementFoundations = { [],[],[],[] };

problem.nodeLoads = { [],[],[],[]};
problem.nodePenalties = { 1,3,[],2};
problem.nodeFoundations = { [],[],[],[] };


% quadrature types
problem.elementQuadratures = poSetupElementQuadratures(problem);


% check and complete problem data structure
problem = poCheckProblem(problem);

Aq = sum( problem.elementQuadratures{1}.weights )*2500;
Aex = 100*100 - pi*(10)^2/4;

e_r = abs( (Aq - Aex) / Aex );

%% analysis
[ allKe, allFe, allLe ] = goCreateElementMatrices( problem );

[ K, F ] = goAssembleSystem(allKe, allFe, allLe);

U = K \ F;

[ allUe ] = goDisassembleVector( U, allLe );

%% conditioning number
% git the matrix of interest
ke2 = allKe{1};

% compute the eigen values
[V,eigV] = eig(ke2);
numberOfEigValuesIncludingBCs = size(eigV,1);

% remove eigen values related to BCs
indices = find(abs(eigV)>1e19);
eigV(indices) = [];

numberOfEigValuesWithoutBCs = size(eigV,1);

% compute the conditioning
minEig = min(eigV);
maxEig = max(eigV);
condition = abs(maxEig/minEig);

%% postprocess results
% plot integration points
% plotAdaptiveGaussLegendre2d( problem, 2)

% plot mesh and boundary conditions
%goPlotMesh(problem,3);
%goPlotLoads(problem,3, 0.03);
%view(2);
%axis equal;

%% plot eigenmodes
V = [
     3.535533905932740e-01    -1.450577950599554e-01    -4.784958057207441e-01    -4.924931515297513e-01    -8.631625395192663e-02     5.908768851404234e-01     6.525570615191663e-02     1.469904739136709e-01
     3.535533905932737e-01     4.784958057207440e-01    -1.450577950599556e-01     8.631625395192680e-02    -4.924931515297511e-01    -5.317010033142899e-02    -6.864606253900395e-02    -6.061853334819616e-01
    -3.535533905932738e-01     4.784958057207438e-01    -1.450577950599556e-01     4.924931515297514e-01     8.631625395192664e-02     5.908768851404236e-01     6.525570615191670e-02     1.469904739136708e-01
     3.535533905932736e-01     1.450577950599557e-01     4.784958057207441e-01    -8.631625395192682e-02     4.924931515297511e-01     2.271811365099368e-01     4.937963271091660e-01    -2.820530420817173e-01
     3.535533905932738e-01    -4.784958057207440e-01     1.450577950599558e-01     4.924931515297511e-01     8.631625395192666e-02     3.105256482990578e-01    -4.971866834962531e-01    -1.771418174865733e-01
    -3.535533905932737e-01    -1.450577950599557e-01    -4.784958057207439e-01    -8.631625395192660e-02     4.924931515297513e-01    -5.317010033142891e-02    -6.864606253900382e-02    -6.061853334819616e-01
    -3.535533905932738e-01     1.450577950599555e-01     4.784958057207437e-01    -4.924931515297513e-01    -8.631625395192677e-02     3.105256482990578e-01    -4.971866834962533e-01    -1.771418174865733e-01
    -3.535533905932737e-01    -4.784958057207440e-01     1.450577950599554e-01     8.631625395192649e-02    -4.924931515297513e-01     2.271811365099367e-01     4.937963271091660e-01    -2.820530420817174e-01];

% D =[ 1.428571428571428e+00                         0                         0                         0                         0                         0                         0                         0
%                          0     7.692307692307693e-01                         0                         0                         0                         0                         0                         0
%                          0                         0     7.692307692307689e-01                         0                         0                         0                         0                         0
%                          0                         0                         0     4.945054945054944e-01                         0                         0                         0                         0
%                          0                         0                         0                         0     4.945054945054941e-01                         0                         0                         0
%                          0                         0                         0                         0                         0     4.880700421736125e-17                         0                         0
%                          0                         0                         0                         0                         0                         0     4.744076505296236e-17                         0
%                          0                         0                         0                         0                         0                         0                         0     4.112635316286080e-17 ];

postGridCells = goCreatePostGrid( problem, 10 );
for i=1:1:8
    allUe{1} = V(:,i);
    allUe{1} = allUe{1};
    goPlotPostGridSolution( problem, allUe, postGridCells, @eoEvaluateStrain, @eoEvaluateSolution,i);
end
