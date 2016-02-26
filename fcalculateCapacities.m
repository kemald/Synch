function [capDirect,capCoop,decision,capDecision] = fcalculateCapacities(P_sd,P_sr,P_rd,PL_sd,PL_sr,PL_rd)
% % (decision = 0) ==> (capCoop > capDirect)
% % (decision = 1) ==> (capCoop < capDirect)

% Capacity of Direct Transmission
capDirect = log2(1 + P_sd*PL_sd);

% Capacity of Cooperative Transmission
capRelay = log2(1 + P_sr*PL_sr);
capCoop = log2(1 + P_sr*PL_sr + P_rd*PL_rd);

% Sanity Check 
if capRelay > capCoop 
    error('There is a problem');
end

if capDirect > capCoop;
    fprintf('Direct transmission is on \n');
    decision = 0;
    capDecision = capDirect;    
else
    fprintf('Cooperative tranmission is on \n');
    decision = 1; 
    capDecision = capCoop;
end
fprintf('Channel capacity:%2.2f \n',capDecision);