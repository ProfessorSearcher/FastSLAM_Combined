workingDir = tempname;
mkdir(workingDir)
mkdir(workingDir,'images')

ii = 1;
video = VideoReader('MOV_0017.mp4');

while hasFrame(video)
   img = readFrame(video);
   filename = [sprintf('%03d',ii) '.jpg'];
   fullname = fullfile(workingDir,'images',filename);
   imwrite(img,fullname)    % Write out to a JPEG file (img1.jpg, img2.jpg, etc.)
   ii = ii+1;
end