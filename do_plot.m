function do_plot(h, particles, xtrue, plines, veh)

xvp = [particles.xv];
xfp = [particles.xf];
w = [particles.w]; 

ii= find(w== max(w)); 
xvmax= xvp(:,ii);

xt= TransformToGlobal(veh,xtrue);
xm= TransformToGlobal(veh,xvmax);
set(h.xt, 'xdata', xt(1,:), 'ydata', xt(2,:))
set(h.xm, 'xdata', xm(1,:), 'ydata', xm(2,:))
set(h.xvp, 'xdata', xvp(1,:), 'ydata', xvp(2,:))
if ~isempty(xfp), set(h.xfp, 'xdata', xfp(1,:), 'ydata', xfp(2,:)), end
if ~isempty(plines), set(h.obs, 'xdata', plines(1,:), 'ydata', plines(2,:)), end
pcov= make_covariance_ellipses(particles(ii(1)));
if ~isempty(pcov), set(h.cov, 'xdata', pcov(1,:), 'ydata', pcov(2,:)); end

drawnow
hold off
end

function p= make_covariance_ellipses(particle)
N= 10;
inc= 2*pi/N;
phi= 0:inc:2*pi;
circ= 2*[cos(phi); sin(phi)];

p= make_ellipse(particle.xv(1:2), particle.Pv(1:2,1:2) + eye(2)*eps, circ);

lenf= size(particle.xf,2);
if lenf > 0
    
    xf= particle.xf;
    Pf= particle.Pf;
    p= [p zeros(2, lenf*(N+2))];

    ctr= N+3;
    for i=1:lenf
        ii= ctr:(ctr+N+1);
        p(:,ii)= make_ellipse(xf(:,i), Pf(:,:,i), circ);
        ctr= ctr+N+2;
    end
end

end

function p= make_ellipse(x,P,circ)
% make a single 2-D ellipse 
r= sqrtm_2by2(P);
a= r*circ;
p(2,:)= [a(2,:)+x(2) NaN];
p(1,:)= [a(1,:)+x(1) NaN];

end
%
%
