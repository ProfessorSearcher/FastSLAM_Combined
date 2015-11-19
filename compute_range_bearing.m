function z= compute_range_bearing(x,lm)
% Compute exact observation using range bearing model
dx= lm(1,:) - x(1);
dy= lm(2,:) - x(2);
phi= x(3);
z= [sqrt(dx.^2 + dy.^2);
    atan2(dy,dx) - phi];
end
