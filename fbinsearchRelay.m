function [lambdaSR,PD_sr,PD_rd] = fbinsearchRelay(PL_sd,PL_sr,PL_rd,Pmax,lambdaMin,lambdaMax,tol)

lambdaMin0 = lambdaMin;
lambdaMax0 = lambdaMax;

% Source - Relay
Nmax = 100; %log2(abs(lambdaMax - lambdaMin)/tol) + 1; 
ii = 1; 
while abs(lambdaMin - lambdaMax) > tol && Nmax > ii
    lambda(ii) = (lambdaMin + lambdaMax)/2;
    Pd_direct(ii) = max(min(lambda(ii)/PL_rd/(log(2)* (1/PL_sr + 1/PL_rd - 1/PL_sd)) - 1/PL_sr,Pmax),0);
    if Pd_direct(ii) < max(min(lambdaMin/log(2) - 1/PL_sd,Pmax),0);
        lambdaMin = lambda(ii);
    else
        lambdaMax = lambda(ii);
    end
    ii = ii + 1;
end
lambdaSR = lambda(end);
PD_sr = Pd_direct(end);

figure(4);
plot(lambda,log2(1+Pd_direct/PL_sd));

%% Relay - Destination
PD_rd = max(PD_sr*(1/PL_sr-1/PL_sd)/PL_rd,0);

