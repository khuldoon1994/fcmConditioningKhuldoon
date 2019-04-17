function [ values ] = moEvaluateLagrangePolynomials( order, r, derivative )
  
%Evaluation at the GLL-points

[GLPoint]=moGetGaussLobattoQuadraturePoints(order+1);

%Calculation of the Lagrange Polynomials

    values=zeros(1,order+1);

    for i=1:order+1

        nominator = 1;
        denominator = 1;
            for j=1:order+1  
      
                 if i~=j
                    denominator_temp = GLPoint(i) - GLPoint(j);
                    nominator_temp = r - GLPoint(j); 
                    nominator =nominator * nominator_temp;
                    denominator = denominator * denominator_temp;
                else 
                continue
                end
            end 

        values(i)=nominator/denominator;
    end
    
%Calculation of the derivatives
 
    if derivative == 1

    derivatives=zeros(1,order+1);
    
        for i=1:order+1

            sum=0;
                for k=1:order+1

                    nominator = 1;
                    denominator = 1;

                        for j=1:order+1
                            if j~=i && j~=k
                                denominator_temp = GLPoint(i) - GLPoint(j);
                                nominator_temp = r - GLPoint(j); 
                                nominator =nominator * nominator_temp;
                                denominator = denominator * denominator_temp;
                            else 
                                continue
                            end
                        end
                        product=nominator/denominator;
                     
                    if i~=k    
                    sum_temp=product/(GLPoint(i)-GLPoint(k));
                    sum=sum+sum_temp; 
                    
                    else
                      
                    continue    
                        
                    end
                end

            derivatives(i)=sum;    
        end
        
        values=derivatives;
    end        
end