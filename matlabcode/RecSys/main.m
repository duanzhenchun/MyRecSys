clear;
clc;
%% 主函数
%% 包括用 评分数据来产生推荐列表 以及 用社交数据来产生推荐

%% ********************导入基本数据,做一些基础计算**********************************
load ratingSomOutcome1.mat ...
    uniqUserData uniqItemData ...
    userRatingMatrix weight itemClassIndex

userCount=length(uniqUserData);
itemCount=length(uniqItemData);

testSet= load('..\..\..\data\baidu\data1\testSet1.txt');
testUserData=testSet(:,1);
uniqTestUserData=unique(testUserData);
testUserCount=length(uniqTestUserData);



% 将所有用户的权重按降序排列
allSortedWeightCell=GetAllSortedWeight(weight);
userInterestCircleCell=SplitUserByInterestCircle(allSortedWeightCell);
% 将所有item划分到不同簇中
itemInterestCircleCell=SplitItemByInterestCircle(itemClassIndex,size(weight,1));   


%% ***************参数设置及一些初始化工作*********************
topK=50;           % 最终推荐列表前topK个
likeThreshold=3;   % 判断用户是否喜欢一个item的阈值，要大于它
circlePeopleCutRate=0.4;  % 每个兴趣圈子 最后选百分之多少neighbor进行item推荐
topMInterestRate=0.5;   % 取前百分之多少的兴趣

recListLengthRecord=[];  %记录一下每个用户的推荐列表的长度，方便调整topK
totalPrecision=0; totalRecall=0; 
%作为最后计算precision,recall ,f1的分母
count=0;


%% *******************开始迭代************************
for i=1:testUserCount

    the20num=round(0.2*testUserCount);
    if mod(i,the20num)==0
        disp ('20%');
    end
   %% ***********对每个目标用户进行一些初始化****************
    % 待推荐用户ID
    testUser=uniqTestUserData(i);
    % 从训练集中的uniqUserData找 testuser对应的ID
    testUserID=find(uniqUserData==testUser);   
    
    totalInterestRecList=[];  % 基于兴趣的推荐总列表
    totalSocialRecList=[];    % 基于社交的推荐总列表
    finalRecList=[];          % 合并后的总推荐列表
    
%% *********************************迭代第一步，取得目标用户的推荐列表*********************

   %% ***********取得用户前百分之M的兴趣及权重*******************
    %取得目标用户兴趣权值
    interestWeight=allSortedWeightCell{testUserID};
    %考虑用户的所有>0的兴趣
    tx0=find(interestWeight(:,2)>0);
    interestWeight=interestWeight(tx0,:); 
    %取前百分之M的兴趣及其权重
    totalInterestNum=size(interestWeight(:,1),1);
    topInterestNum=ceil(topMInterestRate*totalInterestNum);
    finalTopInterestNum=min(topInterestNum,totalInterestNum);
    interestWeight=interestWeight(1:finalTopInterestNum,:);
    % 计算所有权重的和
    totalWeight=sum(interestWeight(:,2));
    
    %% *************基于目标用户每一个兴趣圈产生一个推荐列表，并去除用户已经看过的*********************
    for j=1:size(interestWeight,1)
        % 算相对权重,最后在合并各兴趣集合，要乘上去
        tempWeight=interestWeight(j,2)/totalWeight;
        % 获取在该兴趣圈的里的人
        userInterestCircle=userInterestCircleCell{interestWeight(j,1)};
        % 在兴趣小组中去除自己
        tx1=find(userInterestCircle(:,1)==testUserID);
        userInterestCircle(tx1,:)=[];         

        itemInterestCircle=itemInterestCircleCell{interestWeight(j,1)};
        interestRecList=GetRecListByInterestCircle(testUserID,userInterestCircle,itemInterestCircle,userRatingMatrix,circlePeopleCutRate);
        % 评分要乘以这个圈子的相对权重
        interestRecList(:,2)=interestRecList(:,2)*tempWeight;
        % 补充加一个备注，包含item所属的兴趣类别ID，到时候再改回来
        completeInterestRecList=zeros(size(interestRecList,1),3);
        completeInterestRecList(:,1:2)=interestRecList;
        completeInterestRecList(:,3)=interestWeight(j,1);
        % 汇总各个兴趣圈子的结果
%         totalInterestRecList=[totalInterestRecList;interestRecList]; 
        totalInterestRecList=[totalInterestRecList;completeInterestRecList]; 
    end
    
    % 对合并后的推荐列表按打分高低进行排序，降序排列
    totalInterestRecList=-sortrows(-totalInterestRecList,2);

    % 去除testUser已经看过的
    watchedItemList=find(userRatingMatrix(testUserID,:)>0);
    [c,ia]=intersect(totalInterestRecList(:,1),watchedItemList);
    totalInterestRecList(ia,:)=[];
    % 记录一下每个用户的推荐列表的长度，方便调整topK
    recListLengthRecord=[recListLengthRecord size(totalInterestRecList,1)];
    % 取前K个，只存ID
%     finalRecList=totalInterestRecList(1:topK,[1,3]);
     finalRecList=totalInterestRecList(1:topK,1);
  
   %% ****************基于目标用户社交圈产生一个推荐列表，并去除用户已经看过的*********************
    % 待完成
    
   %% ***********************合并两个圈子产生的推荐列表***************************************
    % 待完成
   
%% **********************************迭代第二步，取得测试集中目标用户喜欢的item列表***********************   
    % 以评分大于likeThreshold表示喜欢
    testUserLikedItemList=[];
    tempIndex=find(testSet(:,1)==testUser & testSet(:,3)>likeThreshold);
    tempItemSet=testSet(tempIndex,2);
    for m=1:length(tempItemSet)
        itemSetID=find(uniqItemData==tempItemSet(m));
        testUserLikedItemList=[testUserLikedItemList itemSetID];
    end

    if isempty(testUserLikedItemList)
        % 测试集用户中没有评分大于3的item，则不考虑这个用户的推荐，放弃推荐
        continue;
    end

%% **************************************迭代第三步，评测推荐效果****************************************
     % 将推荐列表和测试集中用户喜欢的item取交集，即为hit个数
    hitList=intersect(finalRecList,testUserLikedItemList);
    if isempty(finalRecList) || isempty(testUserLikedItemList)
        disp('there is something wrong with the finalRecList or the testUserLikedItemList');
        continue;
    end
    % 计算单个用户的precision和recall
    precision=length(hitList)/length(finalRecList);
    recall=length(hitList)/length(testUserLikedItemList);
    if isnan(recall) || isnan(precision)
        disp('there is something wrong with the recall or the precision');
    end
    totalPrecision=totalPrecision+precision;
    totalRecall=totalRecall+recall;    
    % 跑到最后的，计数+1，最后作为分母
    count=count+1;
end

%% *******************得到最后的结果****************************
avgPrecision=totalPrecision/count;
avgRecall=totalRecall/count;
avgF1=2*avgPrecision*avgRecall/(avgPrecision+avgRecall);
resultStr=sprintf('the avgPrecision is %f, the avgRecall is %f, avgF1 is %f',avgPrecision,avgRecall,avgF1);
disp(resultStr);
% 计算topK的天花板，超过哪个值，就不能再取了
topKCeil= min(recListLengthRecord);

%% *************将结果保存*****************

fid = fopen('baiduresult.txt','a');
fprintf(fid,'topK = %d, circlePeopleCutRate = %1.2f,topMInterestRate = %1.2f ,likeThreshold= %i \r\n',topK,circlePeopleCutRate,topMInterestRate,likeThreshold);
fprintf(fid,'the avgPrecision is %1.7f, the avgRecall is %1.7f, the avgF1 is %1.7f \r\n',avgPrecision,avgRecall,avgF1);
fprintf(fid,'the topK ceil is %i \r\n\r\n',topKCeil);
fprintf(fid,'--------------------- cutoff line ----------------------- \r\n');
fclose(fid);
 




