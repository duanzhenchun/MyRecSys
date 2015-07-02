clear;
clc;
tic;
% 对Item进行SOM聚类
% 空白处全部赋值为0
trainSet= load('..\..\..\data\baidu\data1\trainSet1.txt');
userData=trainSet(:,1);
itemData=trainSet(:,2);
ratingData=trainSet(:,3);
uniqUserData=unique(userData);
uniqItemData=unique(itemData);
userCount=length(uniqUserData);
itemCount=length(uniqItemData);

% 打印user  item个数
disp(userCount);
disp(itemCount);
disp(length(ratingData));

% 先全部都赋为0，当有分的地方填满后，剩余的以0代替
userRatingMatrix=zeros(userCount,itemCount);  
totalCount=size(trainSet,1);
for m=1:totalCount
    trainCase=trainSet(m,:);  %训练集中的每条记录
    user=trainCase(1);
    item=trainCase(2);
    % 将数据集中的user和item的字符串映射为序数，
    % 以其在uniqUserData和uniqItemData中的位置作为序数
    userID=find(uniqUserData==user);
    itemID=find(uniqItemData==item);
    rating=trainCase(3);
    userRatingMatrix(userID,itemID)=rating;
end

% % 给空白处填入每个用户的平均打分
% for k=1:566
%     tempSum=sum(UserRatingMatrix(k,:));
%     tempCount=length(find(UserRatingMatrix(k,:)>0));
%     meanRatingByUser=tempSum/tempCount;
%     [x,y]=find(UserRatingMatrix(k,:)==0);
%     UserRatingMatrix(k,y)=meanRatingByUser; % 不是x行，而是第k行
% end

addpath '..\..\..\code\matlabcode\SOM'
% 数据归一划
inputdata=userRatingMatrix/5;
height=5;
width=5;
iter=500;
[weight,itemClassIndex]=SomBatch(inputdata,height,width,iter);

% 原始weight 维度为 User个数 x neuro个数，所以要转置
% **********非常重要*********************
weight=weight';
% ***************************************


% weight    维度为 neuro个数 x  User 个数
% itemClassIndex    维度为 itemNum x  1 



% % 对评分矩阵做som的聚类
% net=newsom(userRatingMatrix,[5 5]);
% net.trainParam.epochs = 200;
% net.layers{1}.distanceFcn='dist';
% net=train(net,userRatingMatrix);
% plotsomhits(net,userRatingMatrix);
% weight=net.IW{1,1};
% weight=weight/5;
% 
% % 重新仿真
% itemClass=sim(net,userRatingMatrix);
% % 获得每个item分配到的聚类的编号
% itemClassIndex=vec2ind(itemClass); %1x7000多的 向量

toc;
save ratingSomOutcome3.mat
