function [lambda,Pd_direct] = fbinsearchMe(PL_sd,Pmax,lambdaMin,lambdaMax,tol)

Nmax = log2(abs(lambdaMax - lambdaMin)/tol) + 1; ii = 1; 
while abs(lambdaMin - lambdaMax) > tol && Nmax > ii
    lambda(ii) = (lambdaMin + lambdaMax)/2;
    Pd_direct(ii) = min(lambda(ii)/log(2) - 1/PL_sd,Pmax);
    if Pd_direct(ii) < min(lambdaMin/log(2) - 1/PL_sd,Pmax);
        lambdaMin = lambda(ii);
    else
        lambdaMax = lambda(ii);
    end
    ii = ii + 1;
end
%% Later you can remove (ii) above to implement faster
%% For now I'll keep it for debugging
lambda = lambda(end);
Pd_direct = Pd_direct(end);
% figure(3);
% plot(lambda,log2(1+Pd_direct/PL_sd))
