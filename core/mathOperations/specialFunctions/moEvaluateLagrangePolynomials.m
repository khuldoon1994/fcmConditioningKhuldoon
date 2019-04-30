function [ values ] = moEvaluateLagrangePolynomials( order, r, derivative, samplingPoints)

    if derivative == 0

        values=zeros(1,order+1);
        for i=1:order+1
            nominator = 1;
            denominator = 1;
                for j=1:order+1  

                     if i~=j
                        denominator_temp = samplingPoints(i) - samplingPoints(j);
                        nominator_temp = r - samplingPoints(j); 
                        nominator =nominator * nominator_temp;
                        denominator = denominator * denominator_temp;
                    else 
                    continue
                    end
                end 
            values(i)=nominator/denominator;
        end
    
    elseif derivative == 1

        derivatives=zeros(1,order+1);
        for i=1:order+1
            sum=0;
            for k=1:order+1
                nominator = 1;
                denominator = 1;
                    for j=1:order+1
                        if j~=i && j~=k
                            denominator_temp = samplingPoints(i) - samplingPoints(j);
                            nominator_temp = r - samplingPoints(j); 
                            nominator =nominator * nominator_temp;
                            denominator = denominator * denominator_temp;
                        else 
                            continue
                        end
                    end
                    product=nominator/denominator;
                if i~=k    
                    sum_temp=product/(samplingPoints(i)-samplingPoints(k));
                    sum=sum+sum_temp; 
                else
                    continue    
                end
            end
            derivatives(i)=sum;    
        end
        values=derivatives;
        
    else
        disp('Error! Only first derivatives of Lagrange polynomials cann be evaluated.')
    end
end