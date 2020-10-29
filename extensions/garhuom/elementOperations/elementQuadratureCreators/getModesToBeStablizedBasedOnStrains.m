function [V_hat,D_hat,RBM]=getModesToBeStablizedBasedOnStrains(V,D,B, C, tol, tolStrain)
m = size(D,1);

RBM = 0;
V_hat_rbm = [];
D_hat_rbm = [];
energy_rbm = [];
index_rbm = [];

V_hat = [];
D_hat = [];

%% first identify the RBMs
for i=1:m
    if(D(i)<tol)
        strain = B * V(:,i);
        strainNorm = norm(strain);
        energyDensity = 0.5 * strain' * C * strain;

        if(energyDensity < tolStrain)
            RBM = RBM+1;
            V_hat_rbm(:,end+1) = V(:,i);
            D_hat_rbm(end+1) = D(i);
            energy_rbm(end+1) = energyDensity;
            index_rbm(end+1) = i;
        end
    end
end

%% check if the number of detected RBMs is correct
if (RBM>3)
    V_hat_rbm_n = [];
    D_hat_rbm_n = [];
    index_rbm_n = []; 
    
% find the 3 eigenmodes with the lowest energy and consider them as RBMs
[energy_rbm, ind]=sort(energy_rbm,'ascend'); 
V_hat_rbm=V_hat_rbm(:,ind); 
D_hat_rbm=D_hat_rbm(:,ind);
index_rbm=index_rbm(:,ind);

V_hat_rbm_n(:,end+1) = V_hat_rbm(:,1);
V_hat_rbm_n(:,end+1) = V_hat_rbm(:,2);
V_hat_rbm_n(:,end+1) = V_hat_rbm(:,3);

D_hat_rbm_n(end+1) = D_hat_rbm(1);
D_hat_rbm_n(end+1) = D_hat_rbm(2);
D_hat_rbm_n(end+1) = D_hat_rbm(3);

index_rbm_n(end+1) = index_rbm(1);
index_rbm_n(end+1) = index_rbm(2);
index_rbm_n(end+1) = index_rbm(3);

V_hat_rbm = V_hat_rbm_n;
D_hat_rbm = D_hat_rbm_n;
index_rbm = index_rbm_n;
RBM = size(D_hat_rbm_n,2);
end

%% finally, bad modes that are less than a tolerence excluding RBMs are grouped together
for i=1:m
    if(D(i)<tol)
        if(sum(ismember(index_rbm,i)) == 0)
            V_hat(:,end+1) = V(:,i);
            D_hat(end+1) = D(i);
        end
    end
end