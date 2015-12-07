%Detection of 3D landmarks using FAST corner detection and SFM
%Xuechen Liu 2015

video = VideoReader('testing1.mp4');

%Load camera parameters
load upToScaleReconstructionCameraParameters.mat

while(hasFrame(video)),
    
    %Grab two consecutive frames from one video
    frame1 = readFrame(video);
    frame2 = readFrame(video);
    frame1 = undistortImage(frame1, cameraParams);
    frame2 = undistortImage(frame2, cameraParams);
    
    figure;imshow(rgb2gray(frame1));figure(2);imshow(rgb2gray(frame2));
    
    %Extract and match features using FAST
    points1 = detectFASTFeatures(rgb2gray(frame1));
    points2 = detectFASTFeatures(rgb2gray(frame2));
    features1, valid_points1 = extractFeatures(rgb2gray(frame1), points1);
    features2, valid_points2 = extractFeatures(rgb2gray(frame2), points2);
    pairs = matchFeatures(features1, features2);
    
    %Apply SFM of Multiple Views to get 3D location of landmarks
    
    
end