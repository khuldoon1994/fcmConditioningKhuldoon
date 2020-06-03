% runs all examples, for which a reference solution exists

%% clear variables, close figures
clear all; %#ok
close all;


%% prepare stuff
% disable figures
%set(groot,'defaultFigureVisible','off');
% disable warning
warning('off', 'MATLAB:nearlySingularMatrix'); % get with [a, MSGID] = lastwarn();


%% steps
step1
step2
step3

%% high order fem exercises
highOrderFemExercise11
highOrderFemExercise21
highOrderFemExercise23
highOrderFemExercise31

%% fcm 
exElasticBarFCM

%% others
exElasticBar
exElasticBarConvergenceStudy
exHighOrderFemLectureNodes221
exThreeElementBar
exElasticQuad
exTrussSystem2d


%% reset stuff
%set(groot,'defaultFigureVisible','on');
warning('on', 'MATLAB:nearlySingularMatrix'); % get with [a, MSGID] = lastwarn();
