function p = particle_generator(n_t)
% Generate particles for filtering
%
for i=1:n_t
    p(i).w= 1/n_t; % weight
    p(i).xv= [0;0;0]; % robot pose
    p(i).Pv= zeros(3); % pose covariance
    p(i).xf= []; % features
    p(i).Pf= []; % feature covariances
    p(i).da= []; % data asociation(correspondence)
end




end

