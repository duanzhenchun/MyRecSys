clear;
tic;


version = 1;
trainSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\trainSet%d.txt',version);
socialMatrixFileName = sprintf('..\\..\\..\\data\\baidu\\commondata\\socialMatrix.mat');
uniqueUserFileName =  sprintf('..\\..\\..\\data\\baidu\\commondata\\uniqueUser.mat');
socialTrustFileName='..\\..\\..\\data\\baidu\\commondata\\trustListForSocialMF.txt';
userSocialTrustCellFileName = '..\\..\\..\\data\\baidu\\commondata\\socialTrustCell_socialMF.mat';

load(uniqueUserFileName, 'uniqueUser');
trainSet = load(trainSetFileName);
socialTrustData = load(socialTrustFileName);

load(userSocialTrustCellFileName);
% userSocialTrustCell = GetUserSocialTrustForSocialMF(uniqueUser,uniqueUser,socialTrustData);
% save(userSocialTrustCellFileName,'userSocialTrustCell');

userCount = length(uniqueUser);
itemData=trainSet(:,2);
uniqItemData=unique(itemData);
itemCount=length(uniqItemData);

% set the parameters
iterNum = 200;
tolCost = 1;
factorNum = 20;
alpha = 0.0001; % learning rate
lambda = 0.01;
beta = 0.001;
rm = 1;
wm = 0.002;

saveModelFileName = sprintf('..\\..\\..\\data\\baidu\\socialmfdata_topN\\socialMF_iter%d_fac%d_lamb%1.3f_beta%1.3f.mat',iterNum,factorNum,lambda,beta); % SVD模型文件名

[Q,P] = SocialMF_train(trainSet,userCount, itemCount,rm,wm,uniqueUser, uniqItemData, userSocialTrustCell, iterNum, factorNum, alpha, lambda,  beta, tolCost);

save(saveModelFileName,'Q','P','rm');








toc;

