clc; clear; close all;

% [1]. IEEE P802.15.6/D0 Draft Standard for Body Area Network,? May 2010, DCN: 15-10-0245-06-0006. [Online].
% Available: https: //mentor.ieee.org/802.15/dcn/10/15- 10- 0245- 06- 0006- tg6- draft.doc
% [2]. IEEE Std 802.15.6TM-2012 IEEE Standard for Local and metropolitan area networks Part 15.6: Wireless Body Area Networks
%% Variables
Lp = 255; % MAC payload length
xMCS = 1; % Variable
Nslots = 255; % Variable
AllocSlotLength = 255; % Variable -- AllocSlotLength \in {0,255}
kappa = 1; % Nr of uploads or frames
m = 5; % m-periodic sleep
powerLevel = 1;
%%
xAll = 1:5;
yAll = 10:10:250;
LifeTime = zeros(length(xAll),length(yAll));
sgn = {'-o','-s','-d','-<','->','-v'};
for ii = 1:length(xAll)
    m = xAll(ii);
    for jj = 1:length(yAll)
        Lp = yAll(jj);
        LifeTime(ii,jj) = calculateLifeTime(Lp,xMCS,Nslots,AllocSlotLength,kappa,m,powerLevel);
    end
    lstr{ii} = ['m = ',num2str(m)];
    plot(yAll,LifeTime(ii,:),sgn{ii},'color',rand(3,1),'linewidth',2,'markersize',10); hold on;
end
grid on;
legend(lstr,'fontsize',12);