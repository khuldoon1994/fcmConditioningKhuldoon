function [ timeVector ] = goGetTimeVector(problem)
    %return the time values as an array
    
    tStart = problem.dynamics.tStart;
    tStop = problem.dynamics.tStop;
    nTimeSteps = problem.dynamics.nTimeSteps;
    
    timeVector = linspace(tStart, tStop, nTimeSteps);
end