clc; clear; close all;
% f = -[6 4 4 1 1]; intcon = [2:4]; A = []; b = []; Aeq = [2 2 3 1 2]; beq = 7; lb = [0 0 0 0 0]; ub = [];
f = -[8 11 -6 4]; intcon = [1:4]; A = [5 7 -4 3]; b = 14; Aeq = []; beq = []; lb = zeros(1,4); ub = ones(1,4);
[x,fval,exitflag,output] = intlinprog(f,intcon,A,b,Aeq,beq,lb,ub);
x 
-fval

