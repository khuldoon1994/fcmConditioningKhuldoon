function [ values ] = moEvaluateIntegratedLegendrePolynomials( order, r, derivative )
    
    % temporary
    L = zeros(1,order + 1);
    LD = zeros(1,order + 1);

    L(1) = 1;
    LD(1) = 0;

    % integral
    values = zeros(1,order + 1);
    derivatives = zeros(1,order + 1);
    values(1) = 0.5 * (1.0 - r);
    derivatives(1) = - 0.5;

    if order > 0
        L(2) = r;
        LD(2) = 1;
        values(2) = 0.5 * (1.0 + r);
        derivatives(2) = 0.5;

        i = 1;
        while i < order
            i = i + 1;
            L(i+1) = ( (2 * i - 1) * r * L(i) - (i - 1) * L(i - 1) ) / i;
            LD(i+1) = ( (2 * i - 1) * (L(i) + r * LD(i)) - (i - 1) * LD(i - 1) ) / i;

            values(i+1) = (L(i+1) - L(i - 1)) / sqrt(4 * i - 2);
            derivatives(i+1) = (LD(i+1) - LD(i - 1)) / sqrt(4 * i - 2);
        end
    end
    
    if derivative == 1
      values = derivatives;
    end
end
