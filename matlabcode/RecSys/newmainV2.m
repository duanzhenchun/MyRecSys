clear;
tic;

%% 主函数 v2.0 版
% 基于用户兴趣的推荐
% 分别用评分信息和社交信息来挖掘用户的兴趣
% 找出用户的兴趣后，再基于兴趣社区进行推荐

%% **************对文件导入和存储的目录及名称做设定*********************************
date='6.25';
version=1;   % 第几套数据集
width=8;height=8;

ratingSomFileName=sprintf('..\\..\\..\\data\\baidu\\somdata\\baidu_%dx%d_som%d.mat',width,height,version); 
socialTrustFileName='..\\..\\..\\data\\baidu\\commondata\\trust200.txt';
testSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\testSet%d.txt',version);
resultFileName=sprintf('..\\..\\..\\result\\baidu\\som\\baidu_som_result_%d_%s.txt',version,date);
itemSimiFileName=sprintf('..\\..\\..\\data\\baidu\\ibcfdata\\itemSimiMatrix%d.mat',version);
lessUserFileName='..\\..\\..\\data\\baidu\\commondata\\lessUserID.txt';
moreUserFileName='..\\..\\..\\data\\baidu\\commondata\\moreUserID.txt';
saveAllDataFileName=sprintf('..\\..\\..\\data\\baidu\\somdata\\alldata\\all%d.mat',version);

%% ********************导入之前构建好的数据**********************************

% 导入数据
load(ratingSomFileName, 'uniqUserData', 'uniqItemData', ...
    'userRatingMatrix','weight', 'itemClassIndex');
testSet= load(testSetFileName);
socialTrustData=load(socialTrustFileName);
load(itemSimiFileName,'itemSimiMatrix');
lessUserID=load(lessUserFileName);
moreUserID=load(moreUserFileName);

format long;

%% ******************进行初始化***************************

userCount=length(uniqUserData);
itemCount=length(uniqItemData);
testUserData=testSet(:,1);
uniqTestUserData=unique(testUserData);
testUserCount=length(uniqTestUserData);
interestCount=size(weight,1);

% 一些较为固定的参数
likeThreshold=4;   % 判断用户是否喜欢一个item的阈值，要大于它
recThreshold=3;  % 基于最终兴趣进行推荐时，在每个兴趣圈里，预测评分要大于这个阈值才会被推荐
alpha=0.5; % 兴趣合并的参数，rating=alpha，social=1-alpha
interestCircleThreshold=0.2;  %过滤兴趣用户的阈值，大于这个值的兴趣可以称为真正兴趣，归入到兴趣圈
majorInterestThreshold=0.05; % 考虑是否是主要兴趣

% 取得用户的trust列表
userSocialTrustCell=GetUserSocialTrust(uniqUserData,socialTrustData);

% 获得所有用户的兴趣权重，并按降序排列
% allSortedWeightCell=GetAllSortedWeight(weight);

% 将所有用户划分到不同兴趣簇中去，不同簇之间用户可以重叠
userInterestCircleCell=SplitUserByInterestCircle(weight,interestCircleThreshold);
% 将所有item划分到不同兴趣簇中，簇之间item不重叠
itemInterestCircleCell=SplitItemByInterestCircle(itemClassIndex,interestCount);

% 获得所有用户平均打分
userAvgRating=GetAllUserAvgRating(userRatingMatrix);

%% **** 多个参数组 *******
% topKList=(10:10:100);
% socialNeighbourNumList=(10:10:100);
% for iter1=1:length(topKList)
% topK=topKList(iter1);
% for iter2=1:length(socialNeighbourNumList)
% socialNeighbourNum=socialNeighbourNumList(iter2);
%% ***************参数设置及一些初始化工作*********************
topK=10;           % 最终推荐列表前topK个
socialNeighbourNum=20;

recListLengthRecord=[]; % 记录一下每个用户的推荐列表的长度，方便调整topK
allUserFinalRecList=cell(testUserCount,1);   % 记录对每个用户的推荐列表
% 记录所有用户的结果
allUserResult=ones(length(testUserCount),3)*(-1);
 %记录每个用户的兴趣
allUserInterestSet=cell(testUserCount,1);

totalPrecision=0; totalRecall=0; 
%作为最后计算precision,recall ,f1的分母
totalCount=0;

fprintf('start the iteration ...')
%% *******************开始迭代************************
parfor i=1:testUserCount

%     disp(i);
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
    
    ratingInterestWeight=zeros(interestCount,2);
    ratingInterestWeight(:,1)=(1:interestCount);
    ratingInterestWeight(:,2)=weight(:,testUserID);
   
    % 选择大于阈值的兴趣,其他的不去掉，只是赋值为0，方便后面结合
    idx=find(ratingInterestWeight(:,2)<majorInterestThreshold);
    ratingInterestWeight(idx,2)=0;
    
    % 若全为0，则没必要归一化
    if length(idx)<interestCount
        % 归一化
        totalWeight1=sum(ratingInterestWeight(:,2));
        ratingInterestWeight(:,2)=ratingInterestWeight(:,2)/totalWeight1;
    end
    
    %% ***********取得目标用户基于社交信息得到的兴趣及权重*************
    
    userSocialCircle=userSocialTrustCell{testUserID};
    userSocialCircle=userSocialCircle(1:socialNeighbourNum,:);
    socialInterestWeight=GetSocialInterestWeight(userSocialCircle,weight,majorInterestThreshold);
    % 归一化
    totalWeight2=sum(socialInterestWeight(:,2));
    socialInterestWeight(:,2)=socialInterestWeight(:,2)/totalWeight2;
    
    %% ***************兴趣合并*************************
    mixedInterestWeight=zeros(interestCount,2);
    mixedInterestWeight(:,1)=(1:interestCount);
    mixedInterestWeight(:,2)=alpha*ratingInterestWeight(:,2)+(1-alpha)*socialInterestWeight(:,2);
%     mixedInterestWeight(:,2)=ratingInterestWeight(:,2);
    % 去除为0的兴趣
    tx0=find(mixedInterestWeight(:,2)>0);
    mixedInterestWeight=mixedInterestWeight(tx0,:);
    % 降序排列
    mixedInterestWeight=-sortrows(-mixedInterestWeight,2);
    
    %% ***********取得用户前百分之M的兴趣及权重*******************
    
%     %取前百分之M的兴趣及其权重
%     totalInterestNum=size(mixedInterestWeight(:,1),1);
%     topInterestNum=ceil(topMInterestRate*totalInterestNum);
%     finalTopInterestNum=min(topInterestNum,totalInterestNum);
%     mixedInterestWeight=mixedInterestWeight(1:finalTopInterestNum,:);
    
    % 计算所有权重的和
    totalWeight=sum(mixedInterestWeight(:,2));
    totalInterestRecList=[];
    
    %% ************* 基于目标用户每一个兴趣产生一个推荐列表，并去除用户已经看过的 *********************
    for j=1:size(mixedInterestWeight,1)
        
        % 算相对权重,最后再合并各兴趣集合，要乘上去
        tempWeight=mixedInterestWeight(j,2)/totalWeight;
        % 获取在该兴趣圈的里的人
        userInterestCircle=userInterestCircleCell{mixedInterestWeight(j,1)};
        % 注意兴趣圈为空的情况
        if isempty(userInterestCircle)
            continue
        end
        % 在兴趣小组中去除自己
        idx1=find(userInterestCircle(:,1)==testUserID);
        userInterestCircle(idx1,:)=[];
        % 获取划分到该兴趣圈的item
        itemInterestCircle=itemInterestCircleCell{mixedInterestWeight(j,1)};
        
        % *****基于兴趣进行推荐******     
        interestRecList=GetRecListByInterestCircle(testUserID,userInterestCircle,itemInterestCircle,userRatingMatrix,recThreshold,userAvgRating);
        
        % 第2套方法还有问题，暂时不使用
        %interestRecList=GetRecListByInterestCircle2(testUserID,userInterestCircle,itemInterestCircle,userRatingMatrix,recThreshold,userAvgRating);
        
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
    if isempty(totalInterestRecList)
        continue
    end
    % 对合并后的推荐列表按打分高低进行排序，降序排列
    totalInterestRecList=-sortrows(-totalInterestRecList,2);
    
    % 去除testUser已经看过的
    watchedItemList=find(userRatingMatrix(testUserID,:)>0);
    [c,ia]=intersect(totalInterestRecList(:,1),watchedItemList);
    totalInterestRecList(ia,:)=[];
    
    % 记录一下每个用户的推荐列表的长度，方便调整topK
    if size(totalInterestRecList,1)>0
        recListLengthRecord=[recListLengthRecord size(totalInterestRecList,1)];
    end
    
    % 取前K个，只存ID
    %     finalRecList=totalInterestRecList(1:topK,[1,3]);
    
    % 对topK的设置，不够就不够了
    if length(totalInterestRecList(:,1))<topK
        realTopK=length(totalInterestRecList(:,1));
        finalRecList=totalInterestRecList(1:realTopK,1);
    else
        finalRecList=totalInterestRecList(1:topK,1);
    end
    
    if isempty(finalRecList)
        % 若推荐集合为空，则放弃推荐
        continue;
    end
    
    % 记录每个用户的最终的推荐列表
    allUserFinalRecList{i}=finalRecList;
 
    %% **********************************迭代第二步，取得测试集中目标用户喜欢的item列表***********************
    % 以评分大于likeThreshold表示喜欢

    tempIndex=find(testSet(:,1)==testUser & testSet(:,3)>=likeThreshold);
    tempItemSet=testSet(tempIndex,2);
    
    [commonItem,IA,IB]=intersect(uniqItemData,tempItemSet);
    testUserLikedItemList=IA;
       
%     for m=1:length(tempItemSet)
%         itemSetID=find(uniqItemData==tempItemSet(m));
%         testUserLikedItemList=[testUserLikedItemList itemSetID];
%     end
    
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
   
        
    userInterestSet=zeros(interestCount,7);
    userInterestSet(:,1)= ratingInterestWeight(:,2)>0;  %评分兴趣
    userInterestSet(:,2)= socialInterestWeight(:,2)>0;  %社交兴趣
    combineInterest= userInterestSet(:,1)+userInterestSet(:,2);
    userInterestSet(:,3)=combineInterest==2 ;          % 评分与社交重合兴趣
    extraInterest= userInterestSet(:,2)-userInterestSet(:,1);
    userInterestSet(:,4)= extraInterest==-1 ;  %评分的额外兴趣
    userInterestSet(:,5)= extraInterest==1;    %社交的额外兴趣;
    
    %分析hitList所属的兴趣
    interestHit=GetItemInterest(hitList,itemClassIndex,interestCount);
    userInterestSet(:,6)=interestHit;
    
    % 分析 测试集中relevant 项目所属的兴趣
      
    userInterestSet(:,7)=testUserID;
    allUserInterestSet{i}=userInterestSet;
    
    allUserResult(i,:)=[testUserID,precision,recall];  
    
    % 跑到最后的，计数+1，最后作为分母
    totalCount=totalCount+1;
    
end

%% #####################评价指标###########################
%　分析稀疏用户和正常用户的准确率召回率

% 用于记录稀疏用户和正常用户的结果
lessUserResult=ones(length(lessUserID),3)*(-1);
[~,IA1,~]=intersect(uniqUserData,lessUserID);
lessUserResult(:,1)=IA1;
moreUserResult=ones(length(moreUserID),3)*(-1);
[~,IA2,~]=intersect(uniqUserData,moreUserID);
moreUserResult(:,1)=IA2;

for m=1:length(allUserResult)
    userID=allUserResult(m,1);
    precision=allUserResult(m,2);
    recall=allUserResult(m,3);    
    theID=find(lessUserResult(:,1)==userID);
    if ~isempty(theID)
        lessUserResult(theID,2)=precision;
        lessUserResult(theID,3)=recall;
    else
        theID=find(moreUserResult(:,1)==userID);
        moreUserResult(theID,2)=precision;
        moreUserResult(theID,3)=recall;
    end
end

allUserInterestHitRate=ones(testUserCount,6)*(-1);
% 分析用户的兴趣命中比例
% 1评分 2社交 3重合 4评分额外 5社交额外  6 每个兴趣的命中数
for n=1:length(allUserInterestSet)
    userInterestSet=allUserInterestSet{n};
    if isempty(userInterestSet)
        continue
    end
    testUserID=unique(userInterestSet(:,7));
    interestHit=userInterestSet(:,6);    
    totalHitItrNum=sum(interestHit>0);
    
    ratingHitCover=userInterestSet(:,1)+(interestHit>0);
    ratingHitCoverNum=length(find(ratingHitCover==2));
    
    socialHitCover=userInterestSet(:,2)+(interestHit>0);
    socialHitCoverNum=length(find(socialHitCover==2));
    
    overlapHitCover=userInterestSet(:,3)+(interestHit>0);
    overlapHitCoverNum=length(find(overlapHitCover==2));
    
    ratingExtraHitCover=userInterestSet(:,4)+(interestHit>0);
    ratingExtraHitCoverNum=length(find(ratingExtraHitCover==2));
    
    socialExtraHitCover=userInterestSet(:,5)+(interestHit>0);
    socialExtraHitCoverNum=length(find(socialExtraHitCover==2));
      
    rhCoverRate=ratingHitCoverNum/totalHitItrNum;
    shCoverRate=socialHitCoverNum/totalHitItrNum;
    ohCoverRate=overlapHitCoverNum/totalHitItrNum;
    rehCoverRate=ratingExtraHitCoverNum/totalHitItrNum;
    sehCoverRate=socialExtraHitCoverNum/totalHitItrNum;
       
    allUserInterestHitRate(n,:)=[testUserID,rhCoverRate,shCoverRate,ohCoverRate,rehCoverRate,sehCoverRate];
    if totalHitItrNum==0
        allUserInterestHitRate(n,:)=[testUserID,-1,-1,-1,-1,-1];
    end
end

allUserInterestHitNumRate=ones(testUserCount,6)*(-1);
% 分析用户的兴趣命中数比例
% 1评分 2社交 3重合 4评分额外 5社交额外  6每个兴趣的命中数
for n=1:length(allUserInterestSet)
    userInterestSet=allUserInterestSet{n};
    if isempty(userInterestSet)
        continue
    end
    testUserID=unique(userInterestSet(:,7));
    interestHit=userInterestSet(:,6);    
    totalHitNum=sum(interestHit);
     
    interestHit=interestHit/totalHitNum;
    
    ratingHitCover=userInterestSet(:,1).*interestHit;  
    socialHitCover=userInterestSet(:,2).*interestHit;   
    overlapHitCover=userInterestSet(:,3).*interestHit;  
    ratingExtraHitCover=userInterestSet(:,4).*interestHit;  
    socialExtraHitCover=userInterestSet(:,5).*interestHit;  
      
    rhCoverNumRate=sum(ratingHitCover);
    shCoverNumRate=sum(socialHitCover);
    ohCoverNumRate=sum(overlapHitCover);
    rehCoverNumRate=sum(ratingExtraHitCover);
    sehCoverNumRate=sum(socialExtraHitCover);
       
    allUserInterestHitNumRate(n,:)=[testUserID,rhCoverNumRate,shCoverNumRate,ohCoverNumRate,rehCoverNumRate,sehCoverNumRate];
    if totalHitNum==0
        allUserInterestHitNumRate(n,:)=[testUserID,-1,-1,-1,-1,-1];
    end
end



avgPrecision=totalPrecision/totalCount;
avgRecall=totalRecall/totalCount;
avgF1=2*avgPrecision*avgRecall/(avgPrecision+avgRecall);
allRecListSet=[];

totalILS=0;
acount=0;
for i=1:testUserCount
    recList=allUserFinalRecList{i};
    if length(recList)>1        
        allRecListSet=[allRecListSet recList'];              
        tempILS=GetIntraListSimi(recList,itemSimiMatrix);
        totalILS=totalILS+tempILS;   
        acount=acount+1;       
    end
    
end
avgILS=totalILS/acount;

uniqueAllRecListSet=unique(allRecListSet);
coverage=length(uniqueAllRecListSet)/itemCount;

resultStr=sprintf('the avgPrecision is %f, the avgRecall is %f, avgF1 is %f, coverage is %f, average ILS is %f',avgPrecision,avgRecall,avgF1,coverage,avgILS);
disp(resultStr);
% 计算topK的天花板，超过哪个值，就不能再取了
topKCeil= min(recListLengthRecord);

%% *************将结果保存*****************

fid = fopen(resultFileName,'a');
fprintf(fid,'--------------------------- parameter ---------------------------------\r\n');
fprintf(fid,'topK = %d,likeThreshold= %i ,recThreshold= %1.2f ,socialNeighbour= %d, alpha=%f,interestCircleThreshold=%f,majorInterestThreshold= %f,width=%d,height=%d \r\n',topK,likeThreshold,recThreshold,socialNeighbourNum,alpha,interestCircleThreshold,majorInterestThreshold,width,height);
fprintf(fid,'--------------------------- result ----------------------------------\r\n');
fprintf(fid,'the avgPrecision is %1.7f, the avgRecall is %1.7f, the avgF1 is %1.7f ,the coverage is %f, the avgILS is %f \r\n',avgPrecision,avgRecall,avgF1,coverage,avgILS);
fprintf(fid,'--------------------------  other record ------------------------------\r\n');
fprintf(fid,'the topK ceil is %i \r\n',topKCeil);
fprintf(fid,'the totalCount is %d \r\n',totalCount);
fprintf(fid,'--------------------- cutoff line ----------------------- \r\n\r\n');
fclose(fid);

%保存全部变量，以便之后进行分析
% save(saveAllDataFileName);
% end
% end

toc;

