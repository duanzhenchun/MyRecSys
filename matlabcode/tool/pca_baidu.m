clear;
clc;

% 用pca来压缩评分矩阵
version =1 ;
userRatingMatrixFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\userRatingMatrix%d.mat',version);
saveFileName = sprintf('..\\..\\..\\data\\baidu\\commondata\\reduce_raingMatrix%d.mat',version);

load(userRatingMatrixFileName);
x = userRatingMatrix';  % 1行为1个example , 每个用户表示1个feature;
clear userRatingMatrix;
[coeff, score, latent] = pca(x,'Economy',true); 
m  = cumsum(latent)./sum(latent);
idx = find(m>=0.95);
bestIdx = idx(1);
reduced_ratingMatrix = x(:,1:bestIdx)';

save(saveFileName,'reduced_ratingMatrix');