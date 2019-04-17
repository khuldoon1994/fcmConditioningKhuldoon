function [ shapeFunctions ] = legendreEdgeShapeFunctions( problem, subelementIndex, r, derivative )

    subelementTypeIndex = problem.subelementTypeIndices(subelementIndex);
    p = problem.subelementTypes{subelementTypeIndex}.shapeFunctionEvaluatorData.order;

    if problem.dimension==2

        if derivative==0
            temp = moEvaluateIntegratedLegendrePolynomials(p,r(1),0);
            shapeFunctions = temp(3:end)*0.5*(1+r(2));
        elseif derivative==1
            temp1 = moEvaluateIntegratedLegendrePolynomials(p,r(1),1);
            temp2 = moEvaluateIntegratedLegendrePolynomials(p,r(1),0);
            shapeFunctions = [ temp1(3:end)*0.5*(1+r(2));
                               temp2(3:end)*0.5 ];
        else
              disp('ERROR! Legendre edge shape functions can only handle first derivative.');
        end
        
    elseif problem.dimension==3
        
       if derivative==0
            temp = moEvaluateIntegratedLegendrePolynomials(p,r(1),0);
            shapeFunctions = temp(3:end)*0.25*(1+r(2))*(1+r(3));
            
        elseif derivative==1
            temp1 = moEvaluateIntegratedLegendrePolynomials(p,r(1),1);
            temp2 = moEvaluateIntegratedLegendrePolynomials(p,r(1),0);
            shapeFunctions = [ temp1(3:end) * 0.25 * (1+r(2)) * (1+r(3));
                               temp2(3:end) * 0.25 * (1+r(3));
                               temp2(3:end) * 0.25 * (1+r(2)) ];
        else
              disp('ERROR! Legendre edge shape functions can only handle first derivative.');
        end
    else
        disp('ERROR! Legendre edge shape functions can only handle 2 and 3 dimensions.');
    end

end

