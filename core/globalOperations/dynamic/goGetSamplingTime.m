function [ deltaT ] = goGetSamplingTime(problem)
    %calculate the sampling time of a problem
    
    tStart = problem.dynamics.tStart;
    tStop = problem.dynamics.tStop;
    nTimeSteps = problem.dynamics.nTimeSteps;
    
    deltaT = (tStop - tStart)/(nTimeSteps - 1);
end