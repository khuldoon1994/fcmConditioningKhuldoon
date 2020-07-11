
% load data
load('results/LShape_frame_data.mat');



%% save frames to video
videoObj = VideoWriter('results/results_LShape_Movie.avi', 'Uncompressed AVI');
videoObj.FrameRate = 15;
open(videoObj);
writeVideo(videoObj,Frames);
close(videoObj);

disp(['Movie created.']);