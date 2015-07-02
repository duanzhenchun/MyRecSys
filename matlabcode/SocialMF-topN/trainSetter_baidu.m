clear;
tic;

version = 1;
bigUserRatingMatrixFileName = sprintf('..\\..\\..\\data\\baidu\\commondata\\bigUserRatingMatrix%d.mat',version);
socialMatrixFileName = sprintf('..\\..\\..\\data\\baidu\\commondata\\socialMatrix.mat');
userSocialTrustCellFileName = '..\\..\\..\\data\\baidu\\commondata\\socialTrustCell_socialMF.mat';
socialTrustFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\trustListForSocialMF%d.txt',version);
uniqueUserFileName =  sprintf('..\\..\\..\\data\\baidu\\commondata\\bigUser.mat');

load(bigUserRatingMatrixFileName,'bigUserRatingMatrix');
load(socialMatrixFileName,'socialMatrix');
load(uniqueUserFileName, 'bigUser');
bigUser = unique(bigUser); 
socialTrustData = load(socialTrustFileName);
% load(userSocialTrustCellFileName);
userSocialTrustCell = GetUserSocialTrustForSocialMF(bigUser,socialTrustData);
save(userSocialTrustCellFileName,'userSocialTrustCell');

R = bigUserRatingMatrix;
clear bigUserRatingMatrix;
S = socialMatrix;
clear socialMatrix;

lambda = 0.01;
n_iterations = 300;
n_factors = 20;
epsilon = 0.001;
beta = 0.01;
rm = 1.0;
wm = 0.1;
costTol = 10;
saveModelFileName=sprintf('..\\..\\..\\data\\baidu\\socialmfdata_topN\\socialMF_iter%d_fac_%drm%d_wm%1.3f_beta%1.3f_lamb%1.3f.mat',n_iterations,n_factors,rm,wm,beta,lambda); % SVD模型文件名
[Q,P] = ALSTrain_baidu(R,S,n_factors,n_iterations,lambda,epsilon,beta,rm,wm, userSocialTrustCell,costTol);

save(saveModelFileName,'Q','P','rm');




toc;