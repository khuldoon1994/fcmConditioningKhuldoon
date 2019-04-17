function [ shapeFunctions ] = lagrangeLineShapeFunctions( problem, subelementIndex, r, derivative )

    subelementTypeIndex = problem.subelementTypeIndices(subelementIndex);
    p = problem.subelementTypes{subelementTypeIndex}.shapeFunctionEvaluatorData.order;

    if derivative==0
        temp = moEvaluateLagrangePolynomials(p,r,0);
        shapeFunctions =  [temp(1) temp(end) temp(2:end-1)] ;
    elseif derivative==1
        temp = moEvaluateLagrangePolynomials(p,r,1);
        shapeFunctions =  [temp(1) temp(end) temp(2:end-1)];
    else
          disp('ERROR! Lagrange line shape functions can only handle first derivative.');
    end

    

end