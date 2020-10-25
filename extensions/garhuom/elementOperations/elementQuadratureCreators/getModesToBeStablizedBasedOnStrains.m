function [V_hat,D_hat,RBM]=getModesToBeStablizedBasedOnStrains(V,D,B, C, tol, tolStrain)
RBM = 0;
m = size(D,1);
V_hat = [];
D_hat = [];
V_hat_rbm = [];
D_hat_rbm = [];
energy = [];
index_rbm = [];
%% get all modes that are less than a tolerence without RBM
% for i=1:m
%     if(D(i)<tol)
%         strain = B * V(:,i);
%         strainNorm = norm(strain);
%         energyDensity = 0.5 * strain' * C * strain
%         if(energyDensity < 1.0e-13)
%             RBM = RBM+1;
%         else
%         V_hat(:,end+1) = V(:,i);
%         D_hat(end+1) = D(i);
%         end
%     end
% end

for i=1:m
    if(D(i)<tol)
        strain = B * V(:,i);
        strainNorm = norm(strain);
        energyDensity = 0.5 * strain' * C * strain;

        if(energyDensity < tolStrain)
            RBM = RBM+1;
            V_hat_rbm(:,end+1) = V(:,i);
            D_hat_rbm(end+1) = D(i);
            energy(end+1) = energyDensity;
            index_rbm(end+1) = i;
        end
    end
end
  
if (RBM>3)
    V_hat_rbm_n = [];
    D_hat_rbm_n = [];

    V_hat_rbm_n(:,end+1) = V_hat_rbm(:,1);
    V_hat_rbm_n(:,end+1) = V_hat_rbm(:,2);
    V_hat_rbm_n(:,end+1) = V_hat_rbm(:,3);

    D_hat_rbm_n(end+1) = D_hat_rbm(1);
    D_hat_rbm_n(end+1) = D_hat_rbm(2);
    D_hat_rbm_n(end+1) = D_hat_rbm(3);
    
    RBM = size(D_hat_rbm_n,2);
    V_hat_rbm = V_hat_rbm_n;
    D_hat_rbm = D_hat_rbm_n;
    index_rbm = [1 2 3];
end

for i=1:m
    if(D(i)<tol)
        if(sum(ismember(index_rbm,i)) == 0)
            V_hat(:,end+1) = V(:,i);
            D_hat(end+1) = D(i);
        end
    end
end