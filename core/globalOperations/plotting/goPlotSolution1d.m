function goPlotSolution1d ( problem, allUe, cuts, fig )
% goPlotSolution1d Plots the solution for a one dimensional problem

if problem.dimension~=1
   disp('Error! This function can only handle one-dimensional problems.');
   return;
end

nElements = numel(problem.elementTypeIndices);

x = zeros(cuts+1,nElements);
displacement = zeros(cuts+1,nElements);
strain = zeros(cuts+1,nElements);
stress = zeros(cuts+1,nElements);
nodes = zeros(2,nElements);

for iElement = 1:nElements
    nodes(:,iElement) = problem.nodes(problem.elementNodeIndices{iElement});
    
    elementTypeIndex = problem.elementTypeIndices(iElement);
    elasticityMatrixGetter = problem.elementTypes{elementTypeIndex}.elasticityMatrixGetter;
        
    r = linspace(-1,1,cuts+2);
    for iPoint = 1 : cuts +2
      X=eoEvaluateMapping(problem,iElement,r(iPoint));
      x(iPoint,iElement)=X;
      
      shapes = eoEvaluateShapeFunctions(problem, iElement, r(iPoint));
      N = moComposeInterpolationMatrix(1, shapes);
      displacement(iPoint,iElement)=N * allUe{iElement};
    
      dNdX = eoEvaluateShapeFunctionGlobalDerivative(problem, iElement, r(iPoint));
      B = moComposeStrainDisplacementMatrix(dNdX);
      strain(iPoint,iElement)=B * allUe{iElement};
      
      C = elasticityMatrixGetter(problem, iElement, r(iPoint));
      stress(iPoint,iElement)=C * strain(iPoint,iElement);
      
    end
    
end

figure(fig);
   
subplot(2,2,1);
hold on;
grid on;
h1=plot(nodes, zeros(2,nElements), 'k-o'); 
h2=plot(x,displacement,'r-');
legend([h1(1),h2(1)],{'elements','displacement'});

subplot(2,2,2)
hold on;
grid on;
h1=plot(nodes, zeros(1,2), 'k-o'); 
h2=plot(x,strain,'r-');
legend([h1(1),h2(1)],{'elements','strain'});

subplot(2,2,3)
hold on;
grid on;
h1=plot(nodes, zeros(1,2), 'k-o'); 
h2=plot(x,stress,'r-');
legend([h1(1),h2(1)],{'elements','stress'});


