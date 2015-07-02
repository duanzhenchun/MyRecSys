clear;
clc;
% 并行化版本
% 导入数据 ，其中userNumMap itemNumMap 对旧的序列做映射，
% 映射到新的序列
load ratingSomOutcome1.mat ...
    uniqUserData uniqItemData ...
    userRatingMatrix weight itemClassIndex

userCount=length(uniqUserData);
itemCount=length(uniqItemData);

testSet= load('..\..\..\data\baidu\data1\testSet1.txt');
testUserData=testSet(:,1);
uniqTestUserData=unique(testUserData);
testUserCount=length(uniqTestUserData);
recListLengthRecord=[];

% *************一些参数设置*********************

topK=50;           % 最终推荐列表前topK个
likeThreshold=3;   % 判断用户是否喜欢一个item的阈值，要大于它
circleScreenRate=0.4;  % 每个兴趣圈子 最后选百分之多少neighbor进行item推荐
interestScreenRate=0.4;

% 将所有用户的权重按降序排列
allSortedWeightCell=GetAllSortedWeight(weight);
userInterestCircleCell=SplitUserByInterestCircle(allSortedWeightCell);
% 将所有item划分到不同簇中
itemInterestCircleCell=SplitItemByInterestCircle(itemClassIndex,size(weight,1));

totalPrecision=0;
totalRecall=0;
totalF1=0;
%作为最后计算的分母
count=0;
for i=1:testUserCount
    if mod(i,150)==0
        disp ('20%');
    end

    % 待推荐用户ID
    testUser=uniqTestUserData(i);
    % 从训练集中的uniqUserData找 testuser对应的ID
    testUserID=find(uniqUserData==testUser);   

    % *************取得用户的推荐列表*********************
    %取得目标用户兴趣权值,考虑用户的所有>0的兴趣
    interestWeight=allSortedWeightCell{testUserID};
    tx0=find(interestWeight(:,2)>0);
    interestWeight=interestWeight(tx0,:);
    
    % 只取前百分之 interestScreenRate 的兴趣
    interestNum=size(interestWeight,1);
    finalInterestNum=min(ceil(interestNum*interestScreenRate),interestNum);
    interestWeight=interestWeight(1:finalInterestNum,:);
    
    % 计算所有权重的和
    totalWeight=sum(interestWeight(:,2));
%         topInterestData=interestWeight(1:topInterestNum,:);
    totalInterestRecList=[];
    parfor j=1:size(interestWeight,1)
        %算相对权重,最后在合并各兴趣集合，要乘上去
        tempWeight=interestWeight(j,2)/totalWeight;
        % 获取在该兴趣圈的里的人
        userInterestCircle=userInterestCircleCell{interestWeight(j,1)};
        % 在兴趣小组中去除自己
        tx1=find(userInterestCircle(:,1)==testUserID);
        userInterestCircle(tx1,:)=[];         

        itemInterestCircle=itemInterestCircleCell{interestWeight(j,1)};
        interestRecList=GetRecListByInterestCircle(testUserID,userInterestCircle,itemInterestCircle,userRatingMatrix,circleScreenRate);
        % 评分要乘以这个圈子的相对权重
        interestRecList(:,2)=interestRecList(:,2)*tempWeight;
        % 汇总各个兴趣圈子的结果
        totalInterestRecList=[totalInterestRecList;interestRecList]; 
    end
    % 排序
    totalInterestRecList=-sortrows(-totalInterestRecList,2);

    % 去除testUser已经看过的
    watchedItemList=find(userRatingMatrix(testUserID,:)>0);
    [c,ia]=intersect(totalInterestRecList(:,1),watchedItemList);
    totalInterestRecList(ia,:)=[];
    % 记录一下每个用户的推荐列表的长度，方便调整topK
    recListLengthRecord=[recListLengthRecord size(totalInterestRecList,1)];
    % 取前K个，只存ID
    finalRecList=totalInterestRecList(1:topK,1);

    % ***************取得用户测试集中用户喜欢的item列表*************   
    % 以评分大于likeThreshold表示喜欢
    testUserLikedItemList=[];
    tempIndex=find(testSet(:,1)==testUser & testSet(:,3)>likeThreshold);
    tempItemSet=testSet(tempIndex,2);
    for m=1:length(tempItemSet)
        itemSetID=find(uniqItemData==tempItemSet(m));
        testUserLikedItemList=[testUserLikedItemList itemSetID];
    end

    if isempty(testUserLikedItemList)
        % 测试集用户中没有评分大于3的item，则不考虑这个用户的推荐，放弃
        continue;
    end

    % ****************评测推荐效果********************************
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
    if precision==0 || recall==0
        f1=0;
    else 
        f1=2*precision*recall/(precision+recall);
    end
    totalPrecision=totalPrecision+precision;
    totalRecall=totalRecall+recall;    
    totalF1=totalF1+f1;
    % 跑到最后的，计数+1，最后作为分母
    count=count+1;
end

avgPrecision=totalPrecision/count;
avgRecall=totalRecall/count;
avgF1=totalF1/count;
resultStr=sprintf('the avgPrecision is %f, the avgRecall is %f, avgF1 is %f',avgPrecision,avgRecall,avgF1);
disp(resultStr);

%     resultMatrix(mark,4)=avgPrecision;
%     resultMatrix(mark,5)=avgRecall;
%     resultMatrix(mark,6)=avgF1;
% end












