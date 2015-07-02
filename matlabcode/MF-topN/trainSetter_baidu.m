clear;
tic;

% versionSum=10;

for version = 1:30
% version =1;
fprintf('current version is %d \n',version)
userRatingMatrixFileName = sprintf('..\\..\\..\\data\\baidu\\commondata\\userRatingMatrix%d.mat',version);
load(userRatingMatrixFileName,'userRatingMatrix');
userRatingMatrix = full(userRatingMatrix);

% 参数设置
R = userRatingMatrix;
clear userRatingMatrix;
n_iterations = 300;
lambda = 0.1;
n_factors = 20;
rm = 1.0;
wm = 0.4;
costTol = 10;
saveModelFileName = sprintf('..\\..\\..\\data\\baidu\\mfdata_topN\\MF_fac%d_rm%d_wm%1.3f_lamb%1.3f_ver%d.mat',n_factors,rm,wm,lambda,version); %SVD模型文件名

[Q,P] = ALSTrain_baidu(R,n_factors,n_iterations,lambda,rm,wm,costTol);

save(saveModelFileName,'Q','P','rm');

end
toc;