cap = cv.VideoCapture('MOV_0017.mp4');

detector = cv.FeatureDetector('ORB');
extractor = cv.DescriptorExtractor('ORB');

while(1),
    flag1, img1 = cap.read();
    img1 = imresize(img1, 0.25);
    gr1 = cv.cvtColor(img1, 'RGB2GRAY');
    flag2, img2 = cap.read();
    img2 = imresize(img2, 0.25);
    gr2 = cv.cvtColor(img2, 'RGB2GRAY');
    
    keypoints1 = detector.detect(gr1);
    descriptor1 = extractor.compute(gr1, keypoints1);
    keypoints2 = detector.detect(gr2);
    descriptor2 = extractor.compute(gr2, keypoints2);
    
    

    %pnts = cv.FAST(gr);
    %xx = zeros(2,length(pnts));
%        for i=1:50
%           xx(:,i) = pnts(i).pt;
%        end
%     hold on
%     plot(xx(1,:),xx(2,:),'r.')
    
    pause(0.05);
end
