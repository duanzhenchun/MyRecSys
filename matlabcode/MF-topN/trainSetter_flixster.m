clear;
tic;
for version = 1:30
% version=10;
fprintf('current version is %d \n',version)
userRatingMatrixFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\userRatingMatrix%d.mat',version);
load(userRatingMatrixFileName,'userRatingMatrix');
trainSetFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\trainSet%d.txt',version);
coreUserFileName =sprintf( '..\\..\\..\\data\\flixster\\commondata\\coreUserID%d.txt',version);

trainSet= load(trainSetFileName);
coreUser = load(coreUserFileName);

userData=coreUser;
itemData=trainSet(:,2);
uniqUserData=unique(userData);
uniqItemData=unique(itemData);

userRatingMatrix = full(userRatingMatrix);

% 参数设置
R = userRatingMatrix;
clear userRatingMatrix;
lambda = 0.1;
n_iterations = 300;
n_factors = 20;
rm = -1.0;
wm = 0.2;
costTol = 10;
saveModelFileName=sprintf('..\\..\\..\\data\\flixster\\mfdata_topN\\MF_fac%d_rm%d_wm%1.3f_lamb%1.3f_ver%d.mat',n_factors,rm,wm,lambda,version); %SVD模型文件名

% [Q,P] = ALSTrain_flixster(R, trainSet, uniqUserData ,uniqItemData, n_factors,n_iterations,lambda,rm,wm,costTol);
[Q,P] = ALSTrain_baidu(R, n_factors, n_iterations, lambda, rm, wm, costTol);

save(saveModelFileName,'Q','P','rm');

end
toc;