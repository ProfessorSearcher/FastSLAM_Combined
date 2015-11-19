%%% Configuration file
%%% Permits various adjustments to parameters of the FastSLAM algorithm.
%%% See fastslam_sim.m for more information

% control parameters
V= 3; % m/s
MAXG= 30*pi/180; % radians, maximum steering angle (-MAXG < g < MAXG)
RATEG= 20*pi/180; % rad/s, maximum rate of change in steer angle
WHEELBASE= 4; % metres, vehicle wheel-base
DT_CONTROLS= 0.025; % seconds, time interval between control signals

% control noises
sigmaV= 0.3; % m/s
sigmaG= (3.0*pi/180); % radians
Q= [sigmaV^2 0; 0 sigmaG^2];

% observation parameters
MAX_RANGE= 30.0; % metres
DT_OBSERVE= 8*DT_CONTROLS; % seconds, time interval between observations

% observation noises
sigmaR= 0.1; % metres
sigmaB= (1.0*pi/180); % radians
R= [sigmaR^2 0; 0 sigmaB^2];

% waypoint proximity
AT_WAYPOINT= 1.0; % metres, distance from current waypoint at which to switch to next waypoint
NUMBER_LOOPS= 2; % number of loops through the waypoint list

% resampling
NPARTICLES= 100; 
NEFFECTIVE= 0.75*NPARTICLES; % minimum number of effective particles before resampling

% switches
SWITCH_CONTROL_NOISE= 1;
SWITCH_SENSOR_NOISE = 1;
SWITCH_INFLATE_NOISE= 0;
SWITCH_PREDICT_NOISE = 0;   % sample noise from predict (usually 1 for fastslam1.0 and 0 for fastslam2.0)
SWITCH_SAMPLE_PROPOSAL = 1; % sample from proposal (no effect on fastslam1.0 and usually 1 for fastslam2.0)
SWITCH_HEADING_KNOWN= 0;
SWITCH_RESAMPLE= 1; 
SWITCH_PROFILE= 1;
SWITCH_SEED_RANDOM= 0; % if not 0, seed the randn() with its value at beginning of simulation (for repeatability)

% data association - innovation gates (Mahalanobis distance)
GATE_REJECT= 5.991; % maximum distance for association
GATE_AUGMENT_NN= 2000; % minimum distance for creation of new feature
GATE_AUGMENT= 100; % minimum distance for creation of new feature (100)

% parameters related to SUT
dimv= 3; dimQ= 2; dimR= 2; dimf= 2;

% vehicle update
n_aug=dimv+dimf; 
alpha_aug=0.9; beta_aug=2; kappa_aug=0;
lambda_aug = alpha_aug^2 * (n_aug + kappa_aug) - n_aug; 
lambda_aug=lambda_aug+dimR;
wg_aug = zeros(1,2*n_aug+1); wc_aug = zeros(1,2*n_aug+1);
wg_aug(1) = lambda_aug/(n_aug+lambda_aug);
wc_aug(1) = lambda_aug/(n_aug+lambda_aug)+(1-alpha_aug^2+beta_aug);
for i=2:(2*n_aug+1)
    wg_aug(i) = 1/(2*(n_aug+lambda_aug));    
    wc_aug(i) = wg_aug(i);    
end

% vehicle prediction 
n_r=dimv+dimQ;
alpha_r=0.9;
beta_r=2;
kappa_r=0;
lambda_r = alpha_r^2 * (n_r + kappa_r) - n_r; 
lambda_r= lambda_r+dimR; % should consider dimension of related terms for obtaining equivalent effect with full augmentation
wg_r = zeros(1,2*n_r+1); wc_r = zeros(1,2*n_r+1);
wg_r(1) = lambda_r/(n_r + lambda_r);
wc_r(1) = lambda_r / (n_r+lambda_r) + (1 - alpha_r^2 + beta_r);
for i=2:(2*n_r+1)
    wg_r(i) = 1/(2*(n_r+lambda_r));    
    wc_r(i) = wg_r(i);    
end

%feature updates (augmented state)
n_f_a= dimf + dimR;  
alpha_f_a=0.9; 
beta_f_a=2; 
kappa_f_a=0;
lambda_f_a = alpha_f_a^2 * (n_f_a + kappa_f_a) - n_f_a;
wg_f_a = zeros(1,2*n_f_a+1); wc_f_a = zeros(1,2*n_f_a+1);
wg_f_a(1) = lambda_f_a / (n_f_a + lambda_f_a);
wc_f_a(1) = lambda_f_a / (n_f_a + lambda_f_a) + (1 - alpha_f_a^2 + beta_f_a);
for i=2:(2*n_f_a+1)
    wg_f_a(i) = 1/(2*(n_f_a + lambda_f_a));    
    wc_f_a(i) = wg_f_a(i);    
end
%feature initialization
n_f= dimf;
alpha_f=0.9; 
beta_f=2; 
kappa_f=0;
lambda_f = alpha_f^2 * (n_f + kappa_f) - n_f;
wg_f = zeros(1,2*n_f+1); wc_f = zeros(1,2*n_f+1);
wg_f(1) = lambda_f / (n_f + lambda_f);
wc_f(1) = lambda_f / (n_f + lambda_f) + (1 - alpha_f^2 + beta_f);
for i=2:(2*n_f+1)
    wg_f(i) = 1/(2*(n_f+lambda_f));    
    wc_f(i) = wg_f(i);    
end

