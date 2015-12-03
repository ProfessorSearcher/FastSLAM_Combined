cap = cv.VideoCapture('MOV_0017.mp4');

while(1),
    flag, img = cap.read();
    img = imresize(img, 0.25);
    gr = cv.cvtColor(img, 'RGB2GRAY');
    imshow(gr);hold on;

    pnts = cv.FAST(gr);
    xx = zeros(2,length(pnts));
       for i=1:50
           xx(:,i) = pnts(i).pt;
       end
    hold on
    plot(xx(1,:),xx(2,:),'r.')
    
    pause(0.05);
end
