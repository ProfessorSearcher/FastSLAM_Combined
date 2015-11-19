function [G,iwp]= compute_steering(x, wp, iwp, minD, G, rateG, maxG, dt)
%
% INPUTS:
%   x - true position
%   wp - waypoints
%   iwp - index to current waypoint
%   minD - minimum distance to current waypoint before switching to next
%   G - current steering angle
%   rateG - max steering rate (rad/s)
%   maxG - max steering angle (rad)
%   dt - timestep

% determine if current waypoint reached
cwp= wp(:,iwp);
d2= (cwp(1)-x(1))^2 + (cwp(2)-x(2))^2;
if d2 < minD^2
    iwp= iwp+1; % switch to next
    if iwp > size(wp,2) % reached final waypoint, flag and return
        iwp=0;
        return;
    end    
    cwp= wp(:,iwp); % next waypoint
end

% compute change in G to point towards current waypoint
deltaG= pi_to_pi(atan2(cwp(2)-x(2), cwp(1)-x(1)) - x(3) - G);

% limit rate
maxDelta= rateG*dt;
if abs(deltaG) > maxDelta
    deltaG= sign(deltaG)*maxDelta;
end

% limit angle
G= G+deltaG;
if abs(G) > maxG
    G= sign(G)*maxG;
end

function angle = pi_to_pi(angle)

i= find(angle<-2*pi | angle>2*pi); % replace with a check
if ~isempty(i) 
%    warning('pi_to_pi() error: angle outside 2-PI bounds.')
    angle(i) = mod(angle(i), 2*pi);
end

i= find(angle>pi);
angle(i)= angle(i)-2*pi;

i= find(angle<-pi);
angle(i)= angle(i)+2*pi;

