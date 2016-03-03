clc; clear; close all;

rand('state',1);

N = 4;

nframes = 50;
epsilon = 0.02;

% RSSImin = -90;
% RSSImax = -60;
% RSSI = rand(nframes,1)*(RSSImax-RSSImin) + RSSImin;

PLd0 = 47.14;
nAtt = 4.26;
d = 100; % mm
d0 = 50; % mm 
sigmas = 7.85;
S = sigmas*randn(nframes,1);
RSSI = -(PLd0 + 10*nAtt*log10(d/d0) + S);

ACK = rand(nframes,1)>0.2;
% ACK = ones(nframes,1);
% ACK = zeros(nframes,1); 

[MMSE,Cest,MSE] = WBANChEst(RSSI,ACK,4,nframes,epsilon);
[MMSE2,Cest2,MSE2] = WBANChEst(RSSI,ACK,10,nframes,epsilon);
