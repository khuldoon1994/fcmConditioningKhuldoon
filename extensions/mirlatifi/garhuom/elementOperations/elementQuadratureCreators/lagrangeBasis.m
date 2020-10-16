function evaluatedLagrangePolynomials1D = lagrangeBasis( pointsIn1D, parameter, maxDim, evaluatedLagrangePolynomials1D )

    if ( maxDim > 1 )
      for i = 1:size(pointsIn1D,2)         
        evaluatedLagrangePolynomials1D(i) = 1.0;
        for j = 1:size(pointsIn1D,2)
          if (i ~= j)
            evaluatedLagrangePolynomials1D(i) = evaluatedLagrangePolynomials1D(i) * ...
                (parameter - pointsIn1D(j))/(pointsIn1D(i) - pointsIn1D(j));
          end
        end
      end

    else
      evaluatedLagrangePolynomials1D(1) = 1.0;
    end 
end
