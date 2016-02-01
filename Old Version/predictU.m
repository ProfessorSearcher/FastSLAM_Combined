function particle = predictU( particle,V,G,Q,WB,dt )
%Predicting function using Unscented Transform
%   Detailed explanation goes here
xv= particle.xv;
Pv= particle.Pv;
dimv= size(xv,1);
dimQ= size(Q,1);

global XX PX

XX = [XX; V; G];
PX = blkdiag(PX, Q);

[XX,PX] = unscented_transform(@vehiclemod, @vehiclediff, XX, PX, WB,dt);

particle.xv = XX;
particle.Pv = PX;

%

function x = vehiclemod(x, WB, dt)
V = x(end-1, :);
G = x(end, :);
x = x(1:end-2, :);

x(1:3, :) = vehicle_model(x, V,G, WB,dt);

end
%

function dx = vehiclediff(x1, x2)
dx = x1 - x2;
dx(3,:) = pi_to_pi(dx(3,:));
end


end

