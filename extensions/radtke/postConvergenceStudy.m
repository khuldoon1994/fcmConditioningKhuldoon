

error=zeros(4,6);

load('reference.mat');
ref = data;

for i = 1:3
    timeStepsBy500 = 2^(i-1);
    error(i+1,1) = timeStepsBy500*500;
    
    for j=1:5
        Nby30 = 2^(j-1);
        error(1,j+1)=Nby30*30;
        load(['result_',num2str(Nby30*30),'_',num2str(timeStepsBy500*500),'.mat'],'data');
        
        error(i+1,j+1) = norm(ref.displacementAtMiddleNode2-data.displacementAtMiddleNode2)/norm(ref.displacementAtMiddleNode2);
    end
end

