clear all
close all

order=2;

[X]=moGetGaussLobattoQuadraturePoints(order+1);


syms r

for i=1:order+1
    
    numer=1;
    denom=1;
    
        for j=1:order+1  
            if i~=j
  
                denom_temp = X(i) - X(j);
                numer_temp = r - X(j); 
            
                numer = numer * numer_temp;
                denom = denom * denom_temp;
            else 
            
            continue
        
            end
        end 
        
    value(i)=numer/denom;
    
end  


%Derivative of the shape function

for i=1:order+1
    
    sum=0;
    
    for m=1:order+1
        
       if i~=m
           
        sum_temp=1/(r-X(m));
        
        sum=sum+sum_temp;
           
       else
           
           continue
           
       end
        
    end
    
   dvalue(i)=value(i)*sum;
    
end


for k=1:order+1
    
fplot(value(k),[-1,1]);
hold on
%fplot(dvalue(k),[-1,1]);
end

figure(2)
test=zeros(3,50);
r=linspace(-1,1,50);
for i=1:50
    test(:,i)=moEvaluateLagrangePolynomials(2,r(i),1);
end

plot(r,test(1,:))
hold on
plot(r,test(2,:))
plot(r,test(3,:))