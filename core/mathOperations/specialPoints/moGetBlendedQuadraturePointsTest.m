function [ X, W ] = moGetBlendedQuadraturePoints( ng )

if ng < 2
    warning(msg)
end
    
%Calculate blending factor tau
p = (ng-1);

tau = p/(p+1);

%Berechnung der Integrationspunkte durch die Nullstellen der
%Legendre-Polynome
%L_p+1 - tau * L_p-1 = 0
syms x
X = double(vpasolve(legendreP(p+1,x)-tau*legendreP(p-1,x) == 0));
X = sort(X,'descend');
X = X';

W = zeros(1,size(X,2));

    for i=1:size(X,2)

        if p>=3  
            [ L ] = moEvaluateLegendrePolynomials( p+1, X(i) );
            [ dL ] = moEvaluateLegendrePolynomialsFirstDerivatives( p+1, X(i) );

            Lp2 = L(end-1);
            dLp3 = dL(end);
            dLp1 = dL(end-2);

        elseif p==2
            [ L ] = moEvaluateLegendrePolynomials( p+1, X(i) );
            [ dL ] = moEvaluateLegendrePolynomialsFirstDerivatives( p+1, X(i) );

            Lp2 = L(end-1);
            dLp3 = dL(end);
            dLp1 = 1;

        elseif p==1
            [ dL ] = moEvaluateLegendrePolynomialsFirstDerivatives( p+1, X(i) );

            Lp2 = X(i);
            dLp3 = dL;
            dLp1 = 0;

        end

    W(i) = (2*(p*(1+tau)+tau))/(p*(p+1)*Lp2*(dLp3 - tau* dLp1));

    end

end