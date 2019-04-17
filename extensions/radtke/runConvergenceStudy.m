

for i = 1:1
    %timeStepsBy500 = 2^(i-1);
    timeStepsBy500 = 2;
    
    % h-convergence
    for j=1:10
        Nby30 = 2^(j-1);
        data = computeCDM(Nby30,1,timeStepsBy500);
        close all;
        plotResult(data,1);
        drawnow;
        save(['hRefinement_',num2str(Nby30*30),'_',num2str(timeStepsBy500*500),'.mat'],'data');
        clc
    end
end

