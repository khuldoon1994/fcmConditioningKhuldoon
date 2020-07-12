
% load data
load('results/LShape_frame_data.mat');
% load('results/LShape_frame_data1.mat');
% load('results/LShape_frame_data2.mat');
% load('results/LShape_frame_data3.mat');
% 
% clear Frames
% Frames(1001) = struct('cdata',[],'colormap',[]);
% Frames(1:400) = Frames1;
% Frames(401:800) = Frames2;
% Frames(801:1001) = Frames3;


%% save frames to video
videoObj = VideoWriter('results/results_LShape_Movie.avi', 'Uncompressed AVI');
videoObj.FrameRate = 15;
open(videoObj);
writeVideo(videoObj,Frames);
close(videoObj);

disp(['Movie created.']);

