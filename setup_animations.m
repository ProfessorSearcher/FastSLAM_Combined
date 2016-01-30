function h= setup_animations(lm, picture, points)
title('Unscented FastSLAM 2.1: Predict updated by UKF');
figure(10);
subplot(1,2,1);
imshow(picture);hold on;
plot(points.selectStrongest(50)); hold off;

subplot(1,2,2);
plot(lm(1,:),lm(2,:),'g*')
hold on, axis([0,1,0,1])
%plot(wp(1,:),wp(2,:), wp(1,:),wp(2,:),'ro')

h.xt= patch(0,0,'g','erasemode','xor'); % vehicle true
h.xm= patch(0,0,'r','erasemode','xor'); % mean vehicle estimate
h.obs= plot(0,0,'y','erasemode','xor'); % observations
h.xfp= plot(0,0,'r.','erasemode','background'); % estimated features (particle means)
h.xvp= plot(0,0,'r.','erasemode','xor'); % estimated vehicle (particles)
h.cov= plot(0,0,'erasemode','xor'); % covariances of max weight particle
end