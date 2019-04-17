function [ shapeFunctions ] = legendreQuadShapeFunctions( problem, subelementIndex, r, derivative )
% legendreQuadShapeFunctions Evaluates shape functions (integrated legendre polynomials) for
% a quadrilateral (tensor product space).

    subelementTypeIndex = problem.subelementTypeIndices(subelementIndex);
    p = problem.subelementTypes{subelementTypeIndex}.shapeFunctionEvaluatorData.order;

    if derivative==0

        nodalShapeFunctions = linearQuadShapeFunctions( problem, subelementIndex, r, 0 );

        L1 = moEvaluateIntegratedLegendrePolynomials(p,r(1),0);
        L2 = moEvaluateIntegratedLegendrePolynomials(p,r(2),0);

        internalShapeFunctions = zeros(1,(p-1)*(p-1));
        for i1=1:p-1
            for i2=1:p-1
                internalShapeFunctions((i1-1)*(p-1)+i2) = L1(i1+2)*L2(i2+2);
            end
        end

    elseif derivative==1

        nodalShapeFunctions = linearQuadShapeFunctions( problem, subelementIndex, r, 1 );
        
        L1 = moEvaluateIntegratedLegendrePolynomials(p,r(1),0);
        L2 = moEvaluateIntegratedLegendrePolynomials(p,r(2),0);

        dL1 = moEvaluateIntegratedLegendrePolynomials(p,r(1),1);
        dL2 = moEvaluateIntegratedLegendrePolynomials(p,r(2),1);

        internalShapeFunctions = zeros(2,(p-1)*(p-1));
        for i1=1:p-1
            for i2=1:p-1
                internalShapeFunctions(1,(i1-1)*(p-1)+i2) = dL1(i1+2)*L2(i2+2);
                internalShapeFunctions(2,(i1-1)*(p-1)+i2) = L1(i1+2)*dL2(i2+2);
            end
        end
          
    else
          disp('ERROR! Legendre quad shape functions 2d can only handle first derivative.');
    end

    shapeFunctions = [ nodalShapeFunctions internalShapeFunctions ];

end

