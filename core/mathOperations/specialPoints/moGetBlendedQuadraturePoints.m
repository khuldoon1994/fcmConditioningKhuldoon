function [ X, W ] = moGetBlendedQuadraturePoints( ng )

if ng < 2
    warning(msg)
end
    
%Calculation of the blending factor tau:
p = (ng-1);

tau = p/(p+1);

%Calculation of the Blended Quadrature Points: L_p+1 - tau * L_p-1 = 0
syms x
X = double(vpasolve(legendreP(p+1,x)-tau*legendreP(p-1,x) == 0));

%Claculation of the Weights:
W = zeros(size(X,1),1);

    for i=1:size(X,1)

        if p>=3  
            [ L ] = moEvaluateLegendrePolynomials( p, X(i) );
            [ dL ] = moEvaluateLegendrePolynomialsFirstDerivatives( p+1, X(i) );

            Lp = L(end);
            dLp_plus = dL(end);
            dLp_minus = dL(end-2);

        elseif p==2
            [ L ] = moEvaluateLegendrePolynomials( p+1, X(i) );
            [ dL ] = moEvaluateLegendrePolynomialsFirstDerivatives( p+1, X(i) );

            Lp = L(end-1);
            dLp_plus = dL(end);
            dLp_minus = 1;

        elseif p==1
            [ dL ] = moEvaluateLegendrePolynomialsFirstDerivatives( p+1, X(i) );

            Lp = X(i);
            dLp_plus = dL(end);
            dLp_minus = 0;

        end

    W(i) = (2*(p*(1+tau)+tau))/(p*(p+1)*Lp*(dLp_plus - tau* dLp_minus));

    end
X=X';
W=W';

end