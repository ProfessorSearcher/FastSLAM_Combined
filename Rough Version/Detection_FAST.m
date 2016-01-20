%Detection of 3D landmarks using FAST corner detection and SFM
%Xuechen Liu 2015

format compact
path(path, '../')

video = VideoReader('testing1.mp4');

%Load camera parameters
load upToScaleReconstructionCameraParameters.mat

while(hasFrame(video)),
    
    %Grab two consecutive frames from one video
    frame1 = readFrame(video);
    frame2 = readFrame(video);
    frame1 = undistortImage(frame1, cameraParams);
    frame2 = undistortImage(frame2, cameraParams);
        
    %Extract and match features using FAST
    points1 = detectFASTFeatures(rgb2gray(frame1));
    points2 = detectFASTFeatures(rgb2gray(frame2));
    [features1, valid_points1] = extractFeatures(rgb2gray(frame1), points1);
    [features2, valid_points2] = extractFeatures(rgb2gray(frame2), points2);
    pairs = matchFeatures(features1, features2);
    
    %Apply SFM of Multiple Views to get 3D location of landmarks
    
    %Create point tracker
    tracker = vision.PointTracker('MaxBidirectionalError', 1, 'NumPyramidLevels', 5);
    
    % Initialize the point tracker
    points1 = points1.Location;
    initialize(tracker, points1, frame1);
    
    % Track the points
    [points2, validIdx] = step(tracker, frame2);
    matchedPoints1 = points1(validIdx, :);
    matchedPoints2 = points2(validIdx, :);
    
    % Estimate the fundamental matrix
    [fMatrix, epipolarInliers] = estimateFundamentalMatrix(...
        matchedPoints1, matchedPoints2, 'Method', 'MSAC', 'NumTrials', 10000);
    
    % Find epipolar inliers
    inlierPoints1 = matchedPoints1(epipolarInliers, :);
    inlierPoints2 = matchedPoints2(epipolarInliers, :);
    
    %Compute Camera Poses
    [R, t] = cameraPose(fMatrix, cameraParams, inlierPoints1, inlierPoints2);
    
    % Compute the camera matrices for each position of the camera
    % The first camera is at the origin looking along the X-axis. Thus, its
    % rotation matrix is identity, and its translation vector is 0.
    camMatrix1 = cameraMatrix(cameraParams, eye(3), [0 0 0]);
    camMatrix2 = cameraMatrix(cameraParams, R', -t*R');
    
    %Compute the 3D points using triangulation
    points3D = triangulate(matchedPoints1, matchedPoints2, camMatrix1, camMatrix2);
    
    if abs(points3D(1,1)) > 1
        continue;
    end
    
    %Landmark Assignment
    lm = [points3D(1:30,1),points3D(1:30,3)]';
    
    if abs(floor(lm(1,1) / 10)) > 0
        [e,k] = scaling(min(min(lm)));
        lm = lm ./ (10^e);
    end
    
    %Performing UFastSLAM
    UFastSLAM2(lm,t',R);
    
end