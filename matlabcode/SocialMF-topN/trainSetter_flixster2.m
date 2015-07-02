clear;
tic;

version = 1;
bigUserRatingMatrixFileName = sprintf('..\\..\\..\\data\\flixster\\commondata\\bigUserRatingMatrix%d.mat',version);
socialMatrixFileName = sprintf('..\\..\\..\\data\\flixster\\commondata\\socialMatrix%d.mat',version);
trainSetFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\trainSet%d.txt',version);
uniqueUserFileName =  sprintf('..\\..\\..\\data\\flixster\\commondata\\bigUser%d.mat',version);
userSocialTrustCellFileName = sprintf('..\\..\\..\\data\\flixster\\commondata\\socialTrustCell_socialMF%d.mat',version);
socialTrustFileName = sprintf('..\\..\\..\\data\\flixster\\commondata\\trustListForSocialMF%d.txt',version);

trainSet = load(trainSetFileName);
load(uniqueUserFileName, 'bigUser');
bigUser= unique(bigUser);
load(bigUserRatingMatrixFileName,'bigUserRatingMatrix');
load(socialMatrixFileName,'socialMatrix');
socialTrustData = load(socialTrustFileName);

% load(userSocialTrustCellFileName);
userSocialTrustCell = GetUserSocialTrustForSocialMF(bigUser,socialTrustData);
save(userSocialTrustCellFileName,'userSocialTrustCell');

R = bigUserRatingMatrix;
clear bigUserRatingMatrix;
S = socialMatrix;
clear socialMatrix;

uniqueUserdata = bigUser;
itemData=trainSet(:,2);
uniqItemData=unique(itemData);

lambda = 0.001;
n_iterations = 300;
n_factors = 100;
epsilon = 0.001;
beta = 0.001;
rm = -1.0;
wm = 0.02;
costTol= 10;
saveModelFileName=sprintf('..\\..\\..\\data\\flixster\\socialmfdata_topN\\socialMF_iter%d_fac_%drm%d_wm%1.3f_beta%1.3f_lamb%1.3f_ver%d.mat',n_iterations,n_factors,rm,wm,beta,lambda,version); % SVD模型文件名
[Q,P] = ALSTrain_flixster(R, S, n_factors, n_iterations, lambda, epsilon, beta, rm, wm,trainSet,uniqueUserdata,uniqItemData, userSocialTrustCell,costTol);

save(saveModelFileName,'Q','P','rm');




toc;