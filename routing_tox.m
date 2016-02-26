clc; clear; close all;
%% Node Generation
a = 25;
Nrelays = 10;
Nrelaysdisty = 10;
source = -a;
destination = a;
relays = Nrelaysdisty.*(rand(Nrelays,1) + 1i*rand(Nrelays,1) - 0.5 - 0.5i);
%% Noise
BW = 15e3;
NF = 5;
%% PL
fc = 2.4e9;
lambda = 3e8/fc;
Dist_all = [abs(source - relays) abs(destination - relays)];
aExponent = 2.3;
ShadowVar = 10;
PL_alldB = 20*log10(lambda/(4*pi)) - aExponent*10*log10(Dist_all) + normrnd(0,ShadowVar,Nrelays,2);
PL_sddB = 20*log10(lambda/(4*pi)) - aExponent*10*log10(abs(source - destination)) + normrnd(0,ShadowVar,1,1);
PL = 10.^(PL_alldB./10) % keep the minus to make PL as a gain
PL_sd = 10^(PL_sddB/10)
%% Plot S-R-D
plot(real(source),imag(source),'ro','linewidth',5,'markersize',10); hold on;
plot(real(destination),imag(destination),'ro','linewidth',5,'markersize',10); hold on;
plot(real(relays),imag(relays),'ks','linewidth',2,'markersize',5); grid on;
%% Parameters
Pmax = 10^(-7/10); % 23 dBm


%% Flows
flowVal = 1;
randomRelay = randi(Nrelays,1,1);
xMatrix = zeros(Nrelays+2); % (i,j) -> (Nrelays+2) x (Nrelays+2);

xMatrix(1,randomRelay) = flowVal; % S-R: Randomly select one relay
xMatrixf(randomRelay+1,Nrelays+2) = flowVal; % R-D: Connect it to destination
%% Initially Transmit at Max Power
clc;
P_direct = Pmax;
P_sr = Pmax;
P_rd = Pmax;

iRelay = 1;
[capDirect,capCoop,decision,capDecision] = fcalculateCapacities(P_direct,P_sr,P_rd,PL_sd,PL(iRelay,1),PL(iRelay,2))


































%%
% lambdaMin = 0; lambdaMax = 10; tol = 1e-3; 
% [lambda,Pd_direct] = fbinsearchDirect(PL_sd,Pmax,lambdaMin,lambdaMax,tol);
% relayNo = 1;
% [lambdaSR,Pd_sr,Pd_rd] = fbinsearchRelay(PL_sd,PL(relayNo,1),PL(relayNo,2),Pmax,lambdaMin,lambdaMax,tol);
% fprintf('(Direct) Tx: %2.4f mW \n',Pd_direct*1e3);
% fprintf('(Coop) Tx: %2.4f mW (S-R), %2.4f mW (R-D), \n',Pd_sr*1e3,Pd_rd*1e3);

