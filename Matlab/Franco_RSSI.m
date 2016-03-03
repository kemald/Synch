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
%%
a = zeros(nframes,1);
a(1) = 0.5;

Cest = zeros(nframes,1);
Cest0 = zeros(nframes,1);
Cestp = zeros(nframes,1);
Cestn = zeros(nframes,1);

Cest(1) = RSSI(1);
Cest0(1) = RSSI(1);
Cestp(1) = RSSI(1);
Cestn(1) = RSSI(1);

MSE = zeros(nframes,1); 
MSE0 = zeros(nframes,1);
MSEp = zeros(nframes,1);
MSEm = zeros(nframes,1);

for n = 2:nframes
    a0 = a(n-1);
    am = a(n-1) - epsilon;
    ap = a(n-1) + epsilon;
    
    Cest0(n) = a0 * RSSI(n) + (1-a0)*Cest(n-1);
    Cestp(n) = ap * RSSI(n) + (1-ap)*Cest(n-1);
    Cestm(n) = am * RSSI(n) + (1-am)*Cest(n-1);
    
    zz = ((n):-1:(n-N+1));
    zz(zz<=0) = 1;    
    MSE0(n) = sum((Cest0(zz) - RSSI(zz)).^2)/N;
    MSEp(n) = sum((Cest0(zz) - RSSI(zz)).^2)/N;
    MSEm(n) = sum((Cest0(zz) - RSSI(zz)).^2)/N;
    
    if MSEp(n) < MSE0(n) && MSEp(n) < MSEm(n)
        a(n) = ap;
        Cest(n) = Cestp(n);
    elseif MSEm(n) < MSE0(n) && MSEm(n) < MSEp(n)
        a(n) = am;
        Cest(n) = Cestm(n);
    else
        a(n) = a0;
        Cest(n) = Cest0(n);
    end
    MSE(n) = sum((Cest(zz) - RSSI(zz)).^2)/N;
end
figure(1); 
subplot(2,1,1);
plot(1:nframes,RSSI,'-k'); grid on;
hold on;
plot(1:nframes,Cest,'-b','linewidth',2);
ylabel('RSSI and Channel Estimator');

subplot(2,1,2); plot(1:nframes,MSE); grid on;
ylabel('Channel Est. MMSE'); 
%% Fade Margin
ACK = rand(nframes,1)>0.2;
% ACK = ones(nframes,1);
% ACK = zeros(nframes,1); 
rho = 1; % dB
THRl = 2; % dB
THRh = 4; % dB
theta = 3; % dB
K = 10;
delta = 2; % dB
mu = zeros(nframes,1);
mu(1) = 3; % dB
THRmin = zeros(nframes,1)
THRmin(1) = 3;

for n = 2:nframes
    if sqrt(MSE(n)) > mu(n-1) - THRl
        mu(n) = mu(n-1) + rho;
    elseif (MSE(n) > THRmin(n-1)) && (sqrt(MSE(n)) < mu(n-1) - THRh)
        mu(n) = mu(n-1) - rho;
    end
    if ACK(n) == 0
        mu(n) = mu(n-1) + theta;
    end
    if (sqrt(MSE(n)) < delta) && (ACK(n) == 1)
        THRmin(n) = THRmin(n-1) - rho/K;
    elseif sqrt(MSE(n)) < delta && ACK(n) == 0
        THRmin(n) = THRmin(n-1) + rho;
    else
        THRmin(n) =  THRmin(n-1);
    end
end
figure(2); close; figure(2); 
subplot(3,1,1); stem(1:nframes,ACK); 
ylabel('ACK');
subplot(3,1,2); plot(1:nframes,THRmin,'-b'); hold on;
ylabel('THRmin');
subplot(3,1,3); plot(1:nframes,mu,'-.k'); 
ylabel('Fade Margin, \mu(n)'); grid on;
% ylim([min(THRmin) - epsilon max(THRmin) + epsilon]);

MMSE = sum((Cest - RSSI).^2)/nframes;
fprintf('MMSE:%2.2f \n',MMSE);