function particle = update(particle,z,R,idf)
%UPDATE Summary of this function goes here
%   Detailed explanation goes here
xv = particle.xv;
Pv = particle.Pv;

for i=1:length(idf)
    [xv_u,Pv_u] = unscented_update(@observe_model, @observediff, xv,Pv, z(:,i),R, idf(i));
    particle.xv = xv_u;
    particle.Pv = Pv_u;
end

end

%

function dz = observediff(z1, z2)
dz = z1-z2;
dz(2,:) = pi_to_pi(dz(2,:));


end

