function [ deltaTCrit ] = cdmCriticalSamplingTime(M, K)
    %calculate the critical sampling time for the undamped system
        
    % calculate eigenvalues and eigenvectors
    fullK = full(K);
    fullM = full(M);
    eigVal = eig(fullK, fullM);
    
    % eigenfrequencies
    eigOmega = sqrt(eigVal);
    
    % critical sampling time
    deltaTCrit = 2/max(eigOmega);    
end