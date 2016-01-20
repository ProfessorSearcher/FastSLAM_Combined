function h= setup_animations(lm)
figure
plot(lm(1,:),lm(2,:),'g*')
hold on, axis equal

h.xt= patch(0,0,'g','erasemode','xor'); % vehicle true
h.xm= patch(0,0,'r','erasemode','xor'); % mean vehicle estimate
h.obs= plot(0,0,'y','erasemode','xor'); % observations
h.xfp= plot(0,0,'r.','erasemode','background'); % estimated features (particle means)
h.xvp= plot(0,0,'r.','erasemode','xor'); % estimated vehicle (particles)
h.cov= plot(0,0,'erasemode','xor'); % covariances of max weight particle

end

