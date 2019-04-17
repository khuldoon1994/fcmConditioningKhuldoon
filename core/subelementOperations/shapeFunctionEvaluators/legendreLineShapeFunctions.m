function [ shapeFunctions ] = legendreLineShapeFunctions( problem, subelementIndex, r, derivative )

    subelementTypeIndex = problem.subelementTypeIndices(subelementIndex);
    p = problem.subelementTypes{subelementTypeIndex}.shapeFunctionEvaluatorData.order;

    if derivative==0
        temp = moEvaluateIntegratedLegendrePolynomials(p,r,0);
        shapeFunctions = [ 0.5*(1-r) 0.5*(1+r) temp(3:end) ];
    elseif derivative==1
        temp = moEvaluateIntegratedLegendrePolynomials(p,r,1);
        shapeFunctions = [ -0.5 0.5 temp(3:end) ];
    else
          disp('ERROR! Legendre line shape functions 2d can only handle first derivative.');
    end


end

