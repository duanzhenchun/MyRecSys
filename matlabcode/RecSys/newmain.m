clear;
clc;
tic;

%% 主函数
% 基于用户兴趣的推荐
% 分别用评分信息和社交信息来挖掘用户的兴趣
% 找出用户的兴趣后，再基于兴趣社区进行推荐

%% **************对文件导入和存储的目录及名称做设定*********************************

ratingSomFileName='..\..\..\data\baidu\ratingSomOutcome3.mat';
communityFileName='..\..\..\data\baidu\community1.mat';
socialFileName='..\..\..\data\baidu\data1\finalSocial.txt';
testSetFileName='..\..\..\data\baidu\data1\testSet1.txt';
resultFileName='..\..\..\data\baidu\result\baidu_result1.txt';

%% ********************导入之前构建好的数据**********************************

% addpath '..\..\..\code\matlabcode\FastNewman'
% 导入SOM评分聚类后的结果
load(ratingSomFileName, 'uniqUserData', 'uniqItemData', ...
    'userRatingMatrix','weight', 'itemClassIndex');
% 导入社区划分后的结果
load(communityFileName,'communityCell');
testSet= load(testSetFileName);
socialData=load(socialFileName);
format long;

%% ******************进行初始化***************************

userCount=length(uniqUserData);
itemCount=length(uniqItemData);
testUserData=testSet(:,1);
uniqTestUserData=unique(testUserData);
testUserCount=length(uniqTestUserData);

% 构建邻接矩阵
socialMatrix=zeros(userCount,userCount);
for m=1:size(socialData,1)
    socialLink=socialData(m,:);
    sourceUser=socialLink(1);
    targetUser=socialLink(2);
    sourceUserID=find(uniqUserData==sourceUser);
    targetUserID=find(uniqUserData==targetUser);
    %对称的社交关系
    socialMatrix(sourceUserID,targetUserID)=1;
    socialMatrix(targetUserID,sourceUserID)=1;
end

% 获取用户和社区的映射表，第1列存用户ID，第2列存每个用户所属的社区编号
userCommunityMap=GetUserCommunityMap(communityCell);

% 获取trust信息
% trustMatrixCommuMapCell存每个社区的trust矩阵
% trustNodeMapCell 存每个社区内用户ID的映射，在每个社区内部，要将用户重新从1开始编号，方便处理
% 第1列为映射后的社区内的ID，从1开始，第2列为保留的全局的用户ID编号
[trustMatrixCommuMapCell,trustNodeMapCell]=GetTrustMatrixByCommunity(communityCell,socialMatrix);

% 获得所有用户的兴趣权重，并按降序排列
allSortedWeightCell=GetAllSortedWeight(weight);
% 将所有用户划分到不同兴趣簇中去，不同簇之间用户可以重叠
userInterestCircleCell=SplitUserByInterestCircle(allSortedWeightCell);
% 将所有item划分到不同兴趣簇中，簇之间item不重叠
itemInterestCircleCell=SplitItemByInterestCircle(itemClassIndex,size(weight,1));

% 获得所有用户评价打分
 userAvgRating=GetAllUserAvgRating(userRatingMatrix);

%% **** 多个参数组 *******
% topKList=(10:10:100);
% topMList=(0.5:0.1:1);
% topPeopleRateList=(0.3:0.1:1);
% for iter=1:length(topMList)

%% ***************参数设置及一些初始化工作*********************
topK=50;           % 最终推荐列表前topK个
likeThreshold=3;   % 判断用户是否喜欢一个item的阈值，要大于它
circlePeopleCutRate=0.4;  % 每个兴趣圈子 最后选百分之多少neighbor进行item推荐
topMInterestRate=0.5;   % 取前百分之多少的兴趣
alpha=0.5; % 兴趣合并的参数，rating=alpha，social=1-alpha
recThreshold=3;  % 基于最终兴趣进行推荐时，在每个兴趣圈里，预测评分要大于这个阈值才会被推荐
recListLengthRecord=[];  %记录一下每个用户的推荐列表的长度，方便调整topK
totalPrecision=0; totalRecall=0; 
%作为最后计算precision,recall ,f1的分母
totalCount=0;

%% *******************开始迭代************************
for i=1:testUserCount
% for i=55
    
    the20num=round(0.2*testUserCount);
    if mod(i,the20num)==0
        disp ('20%');
    end
    %% ***********对每个目标用户进行一些初始化****************
    
    % 待推荐用户ID
    testUser=uniqTestUserData(i);
    % 从训练集中的uniqUserData找 testuser对应的ID
    testUserID=find(uniqUserData==testUser);
        
    %% *********************************迭代第一步，取得目标用户的推荐列表*********************
    
    %% ***********取得目标用户基于评分信息得到的兴趣及权重************
    
    ratingInterestWeight=zeros(size(weight,1),2);
    ratingInterestWeight(:,1)=(1:size(weight,1));
    ratingInterestWeight(:,2)=weight(:,testUserID);
    % 归一化
    totalWeight1=sum(ratingInterestWeight(:,2));
    ratingInterestWeight(:,2)=ratingInterestWeight(:,2)/totalWeight1;
    
    %% ***********取得目标用户基于社交信息得到的兴趣及权重*************
    
    userSocialCircle=FindUserSocialCircle(testUserID,userCommunityMap,trustMatrixCommuMapCell,trustNodeMapCell);
    socialInterestWeight=GetSocialInterestWeight(userSocialCircle,weight);
    % 归一化
    totalWeight2=sum(socialInterestWeight(:,2));
    socialInterestWeight(:,2)=socialInterestWeight(:,2)/totalWeight2;
    
    %% ***************兴趣合并*************************
    mixedInterestWeight=zeros(size(weight,1),2);
    mixedInterestWeight(:,1)=(1:size(weight,1));
    mixedInterestWeight(:,2)=alpha*ratingInterestWeight(:,2)+(1-alpha)*socialInterestWeight(:,2);
    % 去除为0的兴趣
    tx0=find(mixedInterestWeight(:,2)>0);
    mixedInterestWeight=mixedInterestWeight(tx0,:);
    % 降序排列
    mixedInterestWeight=-sortrows(-mixedInterestWeight,2);
    
    %% ***********取得用户前百分之M的兴趣及权重*******************
    
    %取前百分之M的兴趣及其权重
    totalInterestNum=size(mixedInterestWeight(:,1),1);
    topInterestNum=ceil(topMInterestRate*totalInterestNum);
    finalTopInterestNum=min(topInterestNum,totalInterestNum);
    mixedInterestWeight=mixedInterestWeight(1:finalTopInterestNum,:);
    % 计算所有权重的和
    totalWeight=sum(mixedInterestWeight(:,2));
    totalInterestRecList=[];
    %% *************基于目标用户每一个兴趣产生一个推荐列表，并去除用户已经看过的*********************
    for j=1:size(mixedInterestWeight,1)
        
        % 算相对权重,最后再合并各兴趣集合，要乘上去
        tempWeight=mixedInterestWeight(j,2)/totalWeight;
        % 获取在该兴趣圈的里的人
        userInterestCircle=userInterestCircleCell{mixedInterestWeight(j,1)};
        % 在兴趣小组中去除自己
        idx1=find(userInterestCircle(:,1)==testUserID);
        userInterestCircle(idx1,:)=[];
        % 获取划分到该兴趣圈的item
        itemInterestCircle=itemInterestCircleCell{mixedInterestWeight(j,1)};
        
        % *****基于兴趣进行推荐******
        interestRecList=GetRecListByInterestCircle(testUserID,userInterestCircle,itemInterestCircle,userRatingMatrix,circlePeopleCutRate,recThreshold);
        
        % 评分要乘以这个圈子的相对权重
        interestRecList(:,2)=interestRecList(:,2)*tempWeight;
        
        % 补充加一个备注，包含item所属的兴趣类别ID，到时候再改回来
        completeInterestRecList=zeros(size(interestRecList,1),3);
        completeInterestRecList(:,1:2)=interestRecList;
        completeInterestRecList(:,3)=mixedInterestWeight(j,1);
        % 汇总各个兴趣圈子的结果
        %         totalInterestRecList=[totalInterestRecList;interestRecList];
        totalInterestRecList=[totalInterestRecList; completeInterestRecList];
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
    
    if isempty(finalRecList)
        % 若推荐集合为空，则放弃推荐
        continue;
    end
    
    
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
    totalCount=totalCount+1;
end

%% *******************得到最后的结果****************************
avgPrecision=totalPrecision/totalCount;
avgRecall=totalRecall/totalCount;
avgF1=2*avgPrecision*avgRecall/(avgPrecision+avgRecall);
resultStr=sprintf('the avgPrecision is %f, the avgRecall is %f, avgF1 is %f',avgPrecision,avgRecall,avgF1);
disp(resultStr);
% 计算topK的天花板，超过哪个值，就不能再取了
topKCeil= min(recListLengthRecord);

%% *************将结果保存*****************

fid = fopen(resultFileName,'a');
fprintf(fid,'topK = %d, circlePeopleCutRate = %1.2f,topMInterestRate = %1.2f ,likeThreshold= %i ,recThreshold= %1.2f  \r\n',topK,circlePeopleCutRate,topMInterestRate,likeThreshold,recThreshold);
fprintf(fid,'the avgPrecision is %1.7f, the avgRecall is %1.7f, the avgF1 is %1.7f \r\n',avgPrecision,avgRecall,avgF1);
fprintf(fid,'the topK ceil is %i \r\n\r\n',topKCeil);
fprintf(fid,'--------------------- cutoff line ----------------------- \r\n');
fclose(fid);


toc;

