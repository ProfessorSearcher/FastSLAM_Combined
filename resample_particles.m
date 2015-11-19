function particles= resample_particles(particles, Nmin, doresample)
%function particles= resample_particles(particles, Nmin, doresample)
%
% Resample particles if their weight variance is such that N-effective
% is less than Nmin.
%

N= length(particles);
w= zeros(1,N);
for i=1:N, w(i)= particles(i).w; end
ws= sum(w); w= w/ws; % Normalization
for i=1:N, particles(i).w= particles(i).w / ws; end

[keep, Neff] = stratified_resample(w);
if Neff < Nmin & doresample==1
    particles= particles(keep);
    for i=1:N, particles(i).w= 1/N; end
end

function [keep, Neff] = stratified_resample(w)
%function [keep, Neff] = stratified_resample(w)
%
% INPUT:
%   w - set of N weights [w1, w2, ..]
%
% OUTPUTS:
%   keep - N indices of particles to keep 
%   Neff - number of effective particles (measure of weight variance)
%
% Tim Bailey 2004.


w= w / sum(w); % normalise
Neff= 1 / sum(w .^ 2); 

len= length(w);
keep= zeros(1,len);
select = stratified_random(len); 
w= cumsum(w); 

ctr=1; 
for i=1:len
   while ctr<=len & select(ctr)<w(i)
       keep(ctr)= i;
       ctr=ctr+1; 
   end
end

function s = stratified_random(N)
%function s = stratified_random(N)
%
% Generate N uniform-random numbers stratified within interval (0,1).
% The set of samples, s, are in ascending order.
%
% Tim Bailey 2003.

k = 1/N;
di = (k/2):k:(1-k/2); % deterministic intervals
s = di + rand(1,N) * k - (k/2); % either within interval

