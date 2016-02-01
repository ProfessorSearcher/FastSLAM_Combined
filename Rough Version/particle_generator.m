function p = particle_generator(np)
%PARTICLE_GENERATOR Summary of this function goes here
%   Detailed explanation goes here

for i=1:np
    p(i).w= 1/np; % initial particle weight
    p(i).xv= zeros(3,1); % initial vehicle pose
    p(i).Pv= eps*eye(3); % initial robot covariance that considers a numerical error
    p(i).Kaiy= []; % temporal keeping for a following measurement update
    p(i).xf= []; % feature mean states
    p(i).Pf= []; % feature covariances    
    p(i).zf= []; % known feature locations
    p(i).idf= []; % known feature index
    p(i).zn= []; % New feature locations   
end


end

