function update_data = UFastSLAM2(lm, pose, Rotation)
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
%Initialization of the system
configfile;n_t = 100;
particles = particle_generator(n_t);
time_step = 660; % The Iteration time is the length of input video
dtsum = 0;

% Initialisation of states and other (global) variables
global XX PX %DATA
XX= zeros(3,1); %just for convenience to be processed globally
xtrue = pose;
PX= eye(3)*eps;
Rot = vrrotmat2vec(Rotation);G = Rot(4);
ftag= 1:size(lm,2); % identifier for each landmark
da_table= zeros(1,size(lm,2)); % data association table 
dt = 1;veh= [0 -WHEELBASE -WHEELBASE; 0 -1 1];
%DATA= initialise_store(XX,PX,XX); % stored data for off-line

h = setup_animations(lm);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for t=1:time_step,
    
    %State Estimation
    for i = 1:n_t,
        %Prediction
        particles(i) = predictU(particles(i),V,G,Q,WHEELBASE,dt);
        % if heading known, observe heading
        particles(i)= observe_heading(particles(i), xtrue(3), SWITCH_HEADING_KNOWN); 
    end
    
    % Observation step
    dtsum= dtsum + dt;
    if dtsum >= DT_OBSERVE
        dtsum= 0;
        
        % Compute true data
        [z,ftag_visible]= get_observations(xtrue, lm, ftag, MAX_RANGE);
        
        if ~isempty(z), plines= make_laser_lines (z,xtrue); end
        
        % Compute (known) data associations
        Nf= size(particles(1).xf,2);
        [zf,idf,zn,da_table]= data_associate_known(z, ftag_visible, da_table, Nf);
        
        % Observe map features
        if ~isempty(zf) 
            
            % compute weights w = w * p(z_k | x_k-1)
            for i=1:NPARTICLES
                w= compute_weightr(particles(i), zf,idf, R);
                particles(i).w= particles(i).w * w;
            end
            
            % resampling *before* computing proposal permits better particle diversity
            particles= resample_particles(particles, NEFFECTIVE, SWITCH_RESAMPLE);            
            
            % unscented update 
            for i=1:NPARTICLES
                particles(i)= updateuf(particles(i),zf,idf, R); 
            end
        end 
        
        % Observe new features, augment map
        if ~isempty(zn)
            for i=1:NPARTICLES
                if isempty(zf) % sample from proposal distribution (if we have not already done so above)
                    particles(i).xv= multivariate_gauss(particles(i).xv, particles(i).Pv, 1);
                    particles(i).Pv= zeros(3);
                end                        
                particles(i)= add_feature(particles(i), zn,R);
            end
        end
        
    end
    
    % plots
    do_plot(h, particles, xtrue, plines, veh)
end

if SWITCH_PROFILE, profile report, end

update_data= particles;

clear global DATA 
clear global XX 
clear global PX

end
%
%



