function update_data = fastslam_main(lm, wp)
% Main execution for a tractable 2D-FastSLAM2.0 algorithm with known path
% with dataset composed of 35 landmarks and 17 waypoints
%
% General FastSLAM steps:
% 0)Apply both motion and observation model(essential to mobile robot)
% 1)Predict: for every particle
%   1.1 predict current pose according to input with random noise
%   1.2 predict current state covariance
% 2)Observe: computing weight using gaussian approximation
% 3)Resampling: Sampling the proposal
% 4)Update landmarks for each particle: EKF/UKF applied
%
% Input: landmarks and waypoints
% Output: Updated particle data with plotting
%
% The program is inspired and mostly adopted from Tim Bailey
% Xuechen Liu 2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialization
n_t = 100;
particles = particle_generator(n_t);
time_step = 150000; % the iteration time
xtrue= zeros(3,1); % Start point of the robot, which is origin

% load parameters of robot
configfile 

% Parameters adapted from Tim bailey
dt= DT_CONTROLS; % change in time between predicts
dtsum= 0; % change in time since last observation
ftag= 1:size(lm,2); % identifier for each landmark
da_table= zeros(1,size(lm,2)); % data association table 
iwp= 1; % index to first waypoint 
G= 0; % initial steer angle
plines=[];

h= setup_animations(lm,wp);
% Formal Simulation
while iwp ~= 0 ,
    % Apply motion model to drive the robot
    % (for further operation it will be estimated, but for now we adopt Tim's)
    [G,iwp]= compute_steering(xtrue, wp, 1, AT_WAYPOINT, G, RATEG, MAXG, dt);
    
    % Compute actual motion (with no control noise)
    xtrue = [xtrue(1) + V*dt*cos(G+xtrue(3,:)); % Standard motion
             xtrue(2) + V*dt*sin(G+xtrue(3,:));
             pi_to_pi(xtrue(3) + V*dt*sin(G)/4)];
    
    % Prediction with non-linear function applied
    for k = 1:n_t,
        xv = particles(k).xv;
        Pv = particles(k).Pv;
        
        % Obtain measurement information
        y_turn = dt*sin(G+xv(3));
        x_turn = dt*cos(G+xv(3));
        
        Gv= [1 0 -V*y_turn; % Non-linear estimation applied for pose prediction
             0 1  V*x_turn;
             0 0 1];
        Gu= [x_turn -y_turn; 
             y_turn  V*x_turn;
             dt*sin(G)/4   V*dt*cos(G)/4];
        
        particles(k).xv= [xv(1) + V*dt*cos(G+xv(3,:)); % Vehicle Motion Model
                          xv(2) + V*dt*sin(G+xv(3,:)); % (Tim Bailey(c) 2004)
                          pi_to_pi(xv(3) + V*dt*sin(G)/4)];
        
        particles(k).Pv = Gv*Pv*Gv' + Gu*Q*Gu'; % Cov of prediction 
        
        % if heading known, observe heading(not the core part of the project)
        particles(k)= observe_heading(particles(k), xtrue(3), SWITCH_HEADING_KNOWN); 

    end
    
    % Observation: computing weight using gaussian approximation
    % The Range-bearing model is applied
    
    dtsum = dtsum + dt;
    if dtsum >= 8 * DT_CONTROLS,
        dtsum = 0; % start a new observation state
        
        [lm_v, idf_v]= get_visible_landmarks(xtrue, lm, ftag, MAX_RANGE);
        
        % Apply range bearing model with noise - nonlinear functional
        % model!
        z = compute_range_bearing(xtrue,lm_v);
        len= size(z,2);
        if len > 0,
            z(1,:)= z(1,:) + randn(1,len)*sqrt(R(1,1));
            z(2,:)= z(2,:) + randn(1,len)*sqrt(R(2,2));
        end
        
        % Compute (known) data associations
        Nf= size(particles(1).xf,2); % Identify new feature
        [zf,idf,zn,da_table]= data_associate_known(z, idf_v, da_table, Nf);
        
        
        % Observe map features
        if ~isempty(zf) 
            
            % compute weights w = w * p(z_k | x_k-1)
            for i=1:NPARTICLES
                w= compute_weightr(particles(i), zf,idf, R);
                particles(i).w= particles(i).w * w;
            end
            
            % resampling *before* computing proposal permits better particle diversity
            particles= resample_particles(particles, NEFFECTIVE, SWITCH_RESAMPLE);            
            
            % sample from "optimal" proposal distribution, then update map 
            for i=1:NPARTICLES
                particles(i)= sample_proposal(particles(i), zf,idf, R, SWITCH_SAMPLE_PROPOSAL); 
                particles(i)= feature_update(particles(i), zf, idf, R);
            end
        end 
            
        % Observe new features, augment map
        if ~isempty(zn)
            for i=1:NPARTICLES
                if isempty(zf) % sample from proposal distribution (if we have not already done so above)
                    particles(i).xv= multivariate_gauss(particles(i).xv, particles(i).Pv, 1);
                    particles(i).Pv= zeros(3);
                end                        
                particles(i)= add_feature(particles(i),zn,R);
            end
        end    
            
            
     end 
        
     % plots
     do_plot(h, particles, xtrue, plines);    
end
        
        
update_data = particles;        
end




