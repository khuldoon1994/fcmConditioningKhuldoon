function [Ke_, Fe_]=applyEigenvalueStablization(Ke, Fe, d, V_hat, D_hat, maxEig, epsilon)

Ke_hat = zeros(size(Ke,2));
Fe_hat = zeros(size(Ke,2),1);

for i=1:size(D_hat,2)
    gamma = epsilon * maxEig - D_hat(i);
    Ke_hat = Ke_hat + gamma * V_hat(:,i)*V_hat(:,i)';
    Fe_hat = Fe_hat + gamma * V_hat(:,i)*V_hat(:,i)' * d;
end

    Ke_ = Ke + Ke_hat;
    Fe_ = Fe + Fe_hat;