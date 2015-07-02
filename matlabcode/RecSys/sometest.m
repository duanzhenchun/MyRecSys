% 分析一下所用的数据的情况

% 获取训练集信息
trainSet= load('..\..\data\mydata1\set\TrainSet1.txt');
userData=trainSet(:,1);
itemData=trainSet(:,2);
uniqUserData=unique(userData);
uniqItemData=unique(itemData);
userCount=length(uniqUserData);
itemCount=length(uniqItemData);
ratingData=trainSet(:,3);
ratingCount=length(ratingData);

% 所有用户的打分的个数的统计矩阵
userRatingCountMatrix=zeros(userCount,2);
for i=1:userCount
    targetUser=uniqUserData(i);
    [tx,ty]=find(trainSet(:,1)==targetUser);
    targetUserRatingCount=length(tx);
    userRatingCountMatrix(i,1)=targetUser;
    userRatingCountMatrix(i,2)=targetUserRatingCount;
%     targetUserRating=trainSet(tx,:);

    
end