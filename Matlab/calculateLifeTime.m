function LifeTime = calculateLifeTime(Lp,xMCS,Nslots,AllocSlotLength,kappa,m,powerLevel,Ackmode)
%     Lp = {1,255} - MAC payload length
%     xMCS -Variable
%     Nslots - Variable
%     AllocSlotLength - Variable -- AllocSlotLength \in {0,255}
%     kappa - Nr of uploads or frames
%     m - m-periodic sleep
%     powerLevel
%% MCS
Rs = 600e3; % ksps
coderate = 51/63.*ones(1,4);
coderate_k = 51.*ones(1,4);
coderate_n = 63.*ones(1,4);
spreadingF = [4 2 1 1];
modulationM = [2 2 2 4];
rate = Rs.*log2(modulationM)./spreadingF.*coderate_k./coderate_n;

% plcpheader = Rs.*log2(2)./4*19/31;
fprintf('Data rate is %2.2f kbps \n',rate(xMCS)/1e3);
%% Frame Structure
% Preamble
Npreamble = 90; % verify this in the standard
tpreamble = Npreamble/Rs;
% Header
Ncoded = 31;
spreadingPLCPHeader = 4;
tPLCheader = Ncoded.*spreadingPLCPHeader/Rs;
% Physical Layer Service Data Unit (PSDU)
L_MACheader = 7; % 7 Octets
L_FCS = 2; % 2 Octets
N_PSDU = 8*(L_MACheader + Lp + L_FCS); % 8 to account for Octets
N_parity = ceil(N_PSDU/coderate_k(xMCS))*(coderate_n(xMCS) - coderate_k(xMCS));
% Padding
N_pad = log2(modulationM(xMCS)).*ceil((N_PSDU + N_parity)/log2(modulationM(xMCS))) - (N_PSDU + N_parity); % verify this on [1]
% Total length of the PSDU in bits after spreading
N_total = (N_PSDU + N_parity + N_pad)*spreadingF(xMCS);
% Frame Duration
tPSDU = N_total/(log2(modulationM(xMCS))*Rs);

pAllocationSlotMin = 1e-3; % Standards says it is 1 msec
pAllcationSlotRes = 1e-3; % Standards says it is 1 msec
Tslot = pAllocationSlotMin + AllocSlotLength * pAllcationSlotRes; % ranges from 1 ms to 256 msec
Tsf = Nslots*Tslot; % range from 1ms to 65.536 seconds
fprintf('Time Slot duration: %2.2f sec \n',Tslot);
fprintf('Super frame duration: %2.2f sec \n',Tsf);
tframe = tpreamble + tPLCheader + tPSDU; % Total time to transmit a frame with MAC payload length of Lp bytes using TX mode xMCS
fprintf('Total time to transmit a frame with MAC payload length of Lp bytes: %2.2f sec \n',tframe);
%% Guard Time
TSIFS = 50e-6;
TIACK = 99.67e-6;
TExtraIFS = 10e-6;
mClockResolution = 4e-6;
HubClockPPM = 40e-6; % mHubClockPPMLimit - ppm
mNominalSynchInterval = 8*Tsf;
SIn = mNominalSynchInterval;
GT0 = TSIFS + TExtraIFS + mClockResolution;
Dn = SIn * HubClockPPM;
GTn = GT0 + 2 * Dn;
GTnx = Tslot/10;
Delta = 10e-6;
if m*Tsf<SIn
    GTSI = ceil(GTnx/Delta)*Delta;
else
    SIa = m*Tsf - SIn;
    Da = SIa * HubClockPPM;
    GTa = 2 * Da;
    GTSI = ceil((GTnx+GTa)/Delta)*Delta;
end
fprintf('Guard Time: %2.6f seconds \n',GTn);
%% State Times
Tbeacon = 20*8/Rs;
Tdata = tframe;
if Ackmode == 1 % B-Ack
    Tcal = 3.13e-3;
    TMIFS = 20e-6;
    TbACK = TIACK*kappa;
    Trx = Tbeacon + TbACK;
    Ttx = kappa * Tdata;
    Trxlisten = GTSI + max(kappa - 1,0) * TMIFS + TSIFS;
    Twakeup = 2*Tcal;
    TStandby = max(m * Tsf - Trx - Ttx - Trxlisten - Twakeup,0);
    fprintf('\nm-superframes: %2.5f sec \n',m*Tsf);
    fprintf('T-rx: %2.5f sec \n',Trx);
    fprintf('T-tx: %2.5f sec \n',Ttx);
    fprintf('T-rxlisten: %2.5f sec \n',Trxlisten);
    fprintf('T-wakeup: %2.5f sec \n',Twakeup);
    fprintf('T-Standby: %2.5f sec \n\n',TStandby);
else % I-Ack
    Tcal = 3.13e-3; 
    Trx = Tbeacon + kappa*TIACK;
    Ttx = kappa * Tdata;
    Trxlisten = GTSI + kappa * TSIFS;
    Twakeup = (kappa + 1) * Tcal;
    TStandby = max(m * Tsf - Trx - Ttx - Trxlisten - Twakeup,0);
    fprintf('\nm-superframes: %2.5f sec \n',m*Tsf);
    fprintf('T-rx: %2.5f sec \n',Trx);
    fprintf('T-tx: %2.5f sec \n',Ttx);
    fprintf('T-rxlisten: %2.5f sec \n',Trxlisten);
    fprintf('T-wakeup: %2.5f sec \n',Twakeup);
    fprintf('T-Standby: %2.5f sec \n\n',TStandby);
end
%%
Irxlisten = 13.8e-3;
Irx = 13.1e-3;
Itx = [11.3e-3 9e-3 7.5e-3 7e-3];
IStandby = 0.9e-6;
Iwakeup = 8.9e-3;
EnergyConsumption = Trx*Irx + Ttx*Itx(powerLevel) + Trxlisten*Irxlisten + Twakeup*Iwakeup + TStandby * IStandby;
if (Trx > m*Tsf) || (Ttx > m*Tsf) || (Trxlisten > m*Tsf) || (Twakeup > m*Tsf) || (TStandby > m*Tsf)
    error('Time cannot be bigger than Tsf');
end
EnergyConsumptionPermSuperFrame =  EnergyConsumption/(m*Tsf);
Qbattery = 560e-3;
LifeTime = Qbattery  / EnergyConsumptionPermSuperFrame /24/365; % hours to years