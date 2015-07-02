clear;

cfulfFileName = sprintf('..\\..\\..\\data\\flixster\\finaldata\\cfulfTopN.txt');
pureTrustFileName = sprintf('..\\..\\..\\data\\flixster\\finaldata\\pureTrustTopN.txt');
trustcfulfFileName = sprintf('..\\..\\..\\data\\flixster\\finaldata\\trustcfulfTopN.txt');
cmimFileName = sprintf('..\\..\\..\\data\\flixster\\finaldata\\cmimTopN.txt');
pbmimFileName = sprintf('..\\..\\..\\data\\flixster\\finaldata\\pbmimTopN.txt');
snmimFileName = sprintf('..\\..\\..\\data\\flixster\\finaldata\\snmimTopN.txt');

cfulfResult = load(cfulfFileName);
pureTrustResult = load(pureTrustFileName);
trustcfulfResult = load(trustcfulfFileName);
cmimResult = load(cmimFileName);
pbmimResult = load(pbmimFileName);
snmimResult = load(snmimFileName);

cfulfResult = cfulfResult * 100;
pureTrustResult = pureTrustResult * 100;
trustcfulfResult = trustcfulfResult * 100;
cmimResult = cmimResult * 100;
pbmimResult = pbmimResult * 100;
snmimResult = snmimResult * 100;


% %% *****************************  precision *************************************************** 
% cfulfY = cfulfResult(:,1);
% pureTrustY = pureTrustResult(:,1);
% trustcfulfY = trustcfulfResult(:,1);
% cmimY = cmimResult(:,1);
% pbmimY = pbmimResult(:,1);
% snmimY = snmimResult(:,1);
% 
% X = (10:10:50);
% 
% p = plot(X,cfulfY,'b-',X,pureTrustY,'g-',X,trustcfulfY,'c-',X,pbmimY,'m-',X,snmimY,'y-',X,cmimY,'r-');
% % grid on;
% xlabel('TopN Size');
% ylabel('precision(%)')
% set(p,'LineWidth',2);
% legend('cf-ulf','pureTrust','trust-cf-ulf','pbmim','sbmim','cmim',1);
% 

% % 
% %% *****************************  recall *************************************************** 
% cfulfY = cfulfResult(:,2);
% pureTrustY = pureTrustResult(:,2);
% trustcfulfY = trustcfulfResult(:,2);
% cmimY = cmimResult(:,2);
% pbmimY = pbmimResult(:,2);
% snmimY = snmimResult(:,2);
% 
% X = (10:10:50);
% 
% p = plot(X,cfulfY,'b-',X,pureTrustY,'g-',X,trustcfulfY,'c-',X,pbmimY,'m-',X,snmimY,'y-',X,cmimY,'r-');
% % grid on;
% xlabel('TopN Size');
% ylabel('recall(%)')
% set(p,'LineWidth',2);
% legend('cf-ulf','pureTrust','trust-cf-ulf','pbmim','sbmim','cmim',2);



%% *****************************  f1 *************************************************** 
cfulfY = cfulfResult(:,3)/100;
pureTrustY = pureTrustResult(:,3)/100;
trustcfulfY = trustcfulfResult(:,3)/100;
cmimY = cmimResult(:,3)/100;
pbmimY = pbmimResult(:,3)/100;
snmimY = snmimResult(:,3)/100;

X = (10:10:50);

p = plot(X,cfulfY,'b-',X,pureTrustY,'g-',X,trustcfulfY,'c-',X,pbmimY,'m-',X,snmimY,'y-',X,cmimY,'r-');
% grid on;
xlabel('TopN Size');
ylabel('F1')
set(p,'LineWidth',2);
legend('cf-ulf','pureTrust','trust-cf-ulf','pbmim','sbmim','cmim',4);
