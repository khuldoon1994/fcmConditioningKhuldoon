%% clear variables, close figures
clear all; %#ok
close all;

%% load
f = @(x) -sin(8*x);
    
%% analytic solution
xRef = linspace(0,1,50);
yRef = -sin(8*xRef) / 64  + cos(8) .* xRef / 8;

%% h-convergence study
figure(1);
p = 1;
for n=1:8

    % problem definition
    problem = poCreateElasticBarProblem(1.0, 1.0, 1.0, p, n, f);
    problem.elementTypes{1}.quadraturePointGetterData.gaussOrder = 10;
    
    % solve
    [ allKe, allFe, allLe ] = goCreateElementMatrices( problem );
    [ K, F ] = goAssembleSystem(allKe, allFe, allLe);
    U = K \ F;
    [ allUe ] = goDisassembleVector( U, allLe );
    
    % plot
    subplot(2,4,n);
    x = problem.nodes;
    y = U;
    
    plot(xRef,yRef,'r-');
    hold on;
    plot(x,y,'k-o');
     
    title(['n = ',num2str(n+1)]); 
end

%% p-convergence study
figure(2);   
n = 1;
for p=1:8

    % problem definition
    problem = poCreateElasticBarProblem(1.0, 1.0, 1.0, p, n, f);
    problem.elementTypes{1}.quadraturePointGetterData.gaussOrder = 10;

    % solve
    [ allKe, allFe, allLe ] = goCreateElementMatrices( problem );
    [ K, F ] = goAssembleSystem(allKe, allFe, allLe);
    U = K \ F;
    [ allUe ] = goDisassembleVector( U, allLe );
    
    % plot
    subplot(2,4,p);
    r = linspace(-1,1,50);
    x = zeros(1,50);
    y = zeros(1,50);
    for i=1:50
        x(i) = eoEvaluateMapping(problem,1,r(i));
        shapes = eoEvaluateShapeFunctions(problem, 1, r(i));
        y(i) = shapes*allUe{1};
    end
    
    plot(xRef,yRef,'r-');
    hold on;
    plot(x,y,'k-');
    
    title(['p = ',num2str(p)]);   
end

if abs(norm(y-yRef)-1.28031121761414639e-04)>1e-17
   error('exHighOrderFemLectureNodes221: Check failed!'); 
else
   disp('exHighOrderFemLectureNodes221: Check passed.');  
end

figure(1)
figure(2)