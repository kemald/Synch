function [lambdaSR,PD_sr,PD_rd] = fbinsearchRelay(PL_sd,PL_sr,PL_rd,Pmax,lambdaMin,lambdaMax,tol)

Pd_direct(1) = max(min(lambdaMax*PL_rd/(log(2)*(PL_sr + PL_rd - PL_sd)) - 1/PL_sr,Pmax),0);
while Pd_direct(1) == 0
    lambdaMin = lambdaMax;
    lambdaMax = lambdaMax*10^3;            
    Pd_direct(1) = max(min(lambdaMax*PL_rd/(log(2)*(PL_sr + PL_rd - PL_sd)) - 1/PL_sr,Pmax),0);
end
% Source - Relay
Nmax = 100; %log2(abs(lambdaMax - lambdaMin)/tol) + 1; 
ii = 2; 
while abs(lambdaMin - lambdaMax) > tol && Nmax > ii            
    lambda(ii) = (lambdaMin + lambdaMax)/2;
    Pd_direct(ii) = max(min(lambda(ii)*PL_rd/(log(2)*(PL_sr + PL_rd - PL_sd)) - 1/PL_sr,Pmax),0);            
    if Pd_direct(ii) < max(min(lambdaMin*PL_rd/(log(2)*(PL_sr + PL_rd - PL_sd)) - 1/PL_sr,Pmax),0)
        lambdaMin = lambda(ii);
    else
        lambdaMax = lambda(ii);
    end
    ii = ii + 1;
end
lambdaSR = lambda(end);
PD_sr = Pd_direct(end);
plot(lambda,Pd_direct)
%% Relay - Destination
PD_rd = max((PL_sr-PL_sd)/PL_rd*PD_sr,0);
%% Capacity for debugging
disp('ere');





