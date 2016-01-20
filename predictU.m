function particle= predictU(particle,v,g,Q,WB,dt)
%PREDICTU Summary of this function goes here
%   Detailed explanation goes here
xv = particle.xv;
Pv = particle.Pv;

xv = [xv; v; g];
Pv = blkdiag(Pv, Q);

[xv_p,Pv_p] = unscented_transform(@vehiclemod, @vehiclediff, xv, Pv, WB,dt);

particle.xv = xv_p;particle.Pv = Pv_p;

end
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

