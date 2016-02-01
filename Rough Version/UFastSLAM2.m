function update_data = UFastSLAM2(lm,pose,Rotation,h)
%This function is designed for Final Year Project: Monocular SLAM
%This function is inspired by the one designed by Bailey, but with UKF
%replacing EKF and data from prior vision system.
%
%General steps in FastSLAM part:
%1)Predict mean and covariance of camera by applying unscented transform
%2)Estimate/Update mean and covariance of camera by applying UKF
%3)Sample from updated posterior(pose) for known features
%4)Initialize new features and update it for new features
%5)Resampling
%6)Update particles
%
%This function does not include waypoints which transforms it from 2D to
%Monocular version.
%
%Xuechen Liu (c) 2015.12.31~2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


configfile; %Load default parameters(think the camera fixed on a robot)

%Compute steering angle from rotation
Rot = vrrotmat2vec(Rotation);
G = Rot(4);

% initialisations
particles= particle_generator(NPARTICLES);
xtrue= zeros(3,1);
veh= [0 -WHEELBASE/10 -WHEELBASE/10; 0 -0.1 0.1];

Qe= Q; Re= R;
if SWITCH_INFLATE_NOISE==1, Qe= 2*Q; Re= 2*R; end

dt= DT_CONTROLS; % change in time between predicts
%dtsum= 0; % change in time since last observation
ftag= 1:size(lm,2); % identifier for each landmark
da_table= zeros(1,size(lm,2)); % data association table 

%Default true position is the one read from the monocular
xtrue = pose;

%Prediction
for i=1:NPARTICLES
    particles(i)= predictU(particles(i), V,G,Q, WHEELBASE,dt);
    particles(i)= observe_heading(particles(i), xtrue(3), SWITCH_HEADING_KNOWN); % if heading known, observe heading
end

%Observation
[z,ftag_visible]= get_observations(xtrue, lm, ftag, MAX_RANGE);
z= add_observation_noise(z,R, SWITCH_SENSOR_NOISE);
plines = [];
if ~isempty(z), plines= make_laser_lines (z,xtrue); end

if isempty(plines), close;return;end

        
%Data Association
Nf= size(particles(1).xf,2);
[zf,idf,zn,da_table]= data_associate_known(z, ftag_visible, da_table, Nf);

%Sample and update the map
for i=1:NPARTICLES
    particles(i)= update(particles(i), zf,Re,idf); %SWITCH_SAMPLE_PROPOSAL; 
end

%Augment the map
if ~isempty(zn)
    for i=1:NPARTICLES
        if isempty(zf) % sample from proposal distribution (if we have not already done so above)
            particles(i).xv= multivariate_gauss(particles(i).xv, particles(i).Pv, 1);
            particles(i).Pv= zeros(3);
        end                        
        particles(i)= add_feature(particles(i), zn,Re); %Keep the Gaussian for further operations
    end
end      

%Plotting
do_plot(h, particles, xtrue, plines, veh)

%if SWITCH_PROFILE, profile report, end

%Update the data
update_data = particles;

end

function p= make_laser_lines (rb,xv)
if isempty(rb), p=[]; return, end
len= size(rb,2);
lnes(1,:)= zeros(1,len)+ xv(1);
lnes(2,:)= zeros(1,len)+ xv(2);
lnes(3:4,:)= TransformToGlobal([rb(1,:).*cos(rb(2,:)); rb(1,:).*sin(rb(2,:))], xv);
p= line_plot_conversion (lnes);
end




