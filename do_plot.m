function do_plot(h, particles, xtrue, plines)

WHEELBASE= 4;
veh= [0 -WHEELBASE -WHEELBASE; 0 -1 1];

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

function p= make_laser_lines (rb,xv)
if isempty(rb), p=[]; return, end
len= size(rb,2);
lnes(1,:)= zeros(1,len)+ xv(1);
lnes(2,:)= zeros(1,len)+ xv(2);
lnes(3:4,:)= TransformToGlobal([rb(1,:).*cos(rb(2,:)); rb(1,:).*sin(rb(2,:))], xv);
p= line_plot_conversion (lnes);

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

function p= make_ellipse(x,P,circ)
% make a single 2-D ellipse 
r= sqrtm_2by2(P);
a= r*circ;
p(2,:)= [a(2,:)+x(2) NaN];
p(1,:)= [a(1,:)+x(1) NaN];

function p = TransformToGlobal(p, b)
% function p = TransformToGlobal(p, b)
%
% Transform a list of poses [x;y;phi] so that they are global wrt a base pose
%
% Tim Bailey 1999

% rotate
rot = [cos(b(3)) -sin(b(3)); sin(b(3)) cos(b(3))];
p(1:2,:) = rot*p(1:2,:);

% translate
p(1,:) = p(1,:) + b(1);
p(2,:) = p(2,:) + b(2);

% if p is a pose and not a point
if size(p,1)==3
   p(3,:) = pi_to_pi(p(3,:) + b(3));
end

function X = sqrtm_2by2(A)
%SQRTM     Matrix square root.
%   X = SQRTM_2by2(A) is the principal square root of the matrix A, i.e. X*X = A.
%          
%   X is the unique square root for which every eigenvalue has nonnegative
%   real part.  If A has any eigenvalues with negative real parts then a
%   complex result is produced.  If A is singular then A may not have a
%   square root.  
%          
% Adapted for speed for 2x2 matrices from the MathWorks sqrtm.m implementation.
% Tim Bailey 2004.

[Q, T] = schur(A);        % T is real/complex according to A.
%[Q, T] = rsf2csf(Q, T);   % T is now complex Schur form.

R = zeros(2);

R(1,1) = sqrt(T(1,1));
R(2,2) = sqrt(T(2,2));
R(1,2) = T(1,2) / (R(1,1) + R(2,2));

X = Q*R*Q';





