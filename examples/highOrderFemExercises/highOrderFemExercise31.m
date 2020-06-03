% Solve the problem considered in exercise 3.1

%% clear variables, close figures
clear all; %#ok
close all;


%% problem definition
problem.name='high order fem exercise 2.1';
problem.dimension = 2;

% polynomial degree
p=5;

% element types
elementType1 = poCreateElementType( 'STANDARD_QUAD_2D', struct('gaussOrder', p+1, 'physics', 'PLANE_STRAIN', 'youngsModulus', 1, 'poissonRatio', 0.3, 'thickness', 1 ));
elementType1.mappingEvaluator = @myBlendedQuadMapping;
elementType1.jacobianEvaluator = @myBlendedQuadJacobian;

elementType2 = poCreateElementType( 'STANDARD_LINE_2D', struct('gaussOrder', p+1, 'physics', 'PLANE_STRAIN', 'youngsModulus', 1, 'poissonRatio', 0.3, 'thickness', 1 ));
elementType2.mappingEvaluator = @myBlendedLineMapping;
elementType2.jacobianEvaluator = @myBlendedLineJacobian;

problem.elementTypes = { elementType1, elementType2 };

% mesh data
h=2;
R=2;
problem.nodes = [ h/2,  R/sqrt(2), h/2, R/sqrt(2);
                 -h/2, -R/sqrt(2), h/2, R/sqrt(2) ];

% elements
problem.elementTopologies = [ 2 1 1 ];
problem.elementTypeIndices = [ 1 2 2 ];
problem.elementNodeIndices = {
    [ 1 2 3 4 ]
    [ 1 3 ]        % needed for penalty constraint 
    [ 2 4 ]        
};

% subelement types
subelementType1 = poCreateSubelementType( 'LEGENDRE_QUAD', struct('order', p) );
subelementType2 = poCreateSubelementType( 'LEGENDRE_EDGE', struct('order', p) );
problem.subelementTypes = { subelementType1, subelementType2 };

% subelements
problem.subelementTopologies = [ 2, 1, 1, 1, 1 ];
problem.subelementTypeIndices = [ 1, 2, 2, 2, 2 ];
problem.subelementNodeIndices = {
    [ 1 2 3 4 ]
    [ 1 2 ]
    [ 3 4 ]
    [ 1 3 ]
    [ 2 4 ]
};

% element connections
problem.elementConnections = {
    { { 1 [ 1, 0; 0, 1] }
      { 2 [ 1, 0; 0,-1] }
      { 3 [ 1, 0; 0, 1] }
      { 4 [ 0, 1;-1, 0] }
      { 5 [ 0, 1; 1, 0] } }
    { { 4 [ 1, 0; 0,-1] } }
    { { 1 [ 0, 1; 1, 0] }
      { 5 [ 1, 0; 0, 1] } }
};



% plot mesh and boundary conditions
postGridCells = goCreatePostGrid( problem, 10 );
goPlotPostGrid( problem, postGridCells, 2);
axis equal;

% compute area
integrand = @( problem, iElement, r, J, detJ) 1.0;
area = eoIntegrateFunction(problem, 1, integrand);
areaRef = 0.5*pi*R-1;
error = abs(area-areaRef);

% disp(['area: ',num2str(area),', error: ',num2str(error)]);

%% check
if error>1e-11
   disp('ERROR! Check failed!'); 
end

