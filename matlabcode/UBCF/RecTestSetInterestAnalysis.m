function [avgUserRecTestItrByLevel,avgExRecTestItrRate]=RecTestSetInterestAnalysis(allUserFinalRecList,testSet,uniqItemData,likeThreshold,itemClassIndex,interestCount,userLevel)

% 分析各个Level用户推荐集合和测试集合中兴趣的分布情况
% 1.推荐集合 和 测试集合中  item所属兴趣种类 的 重合 额外 情况
% 2.推荐集合 和 测试集合众  item所属种类

theCount=0;
totalExRecItrHitNumRate=0;
totalExTestItrHitNumRate=0;

userCount=length(allUserFinalRecList);
allUserRecTestItr=ones(length(userCount),4)*(-100);

for i=1:userCount
    recListCell=allUserFinalRecList{i};
    if isempty(recListCell)
        continue
    end
    user=recListCell{1};
    recList=recListCell{2};    
    
    tempIndex=find(testSet(:,1)==user & testSet(:,3)>=likeThreshold);
    tempItemSet=testSet(tempIndex,2);   
    [~,IA,~]=intersect(uniqItemData,tempItemSet);
    testUserLikedItemList=IA;
    
    %分析recList所属的兴趣分布，返回的是在各个兴趣的命中个数
    recItrHitNum=GetItemInterest(recList,itemClassIndex,interestCount);
    recItrHitNumRate=recItrHitNum/sum(recItrHitNum);
    recItrHit=recItrHitNumRate>0;
    
    %分析testUserLikedItemList所属的兴趣分布，返回的是在各个兴趣的命中个数
    testItrHitNum=GetItemInterest(testUserLikedItemList,itemClassIndex,interestCount);
    testItrHitNumRate=testItrHitNum/sum(testItrHitNum);
    testItrHit=testItrHitNumRate>0;
      
    diffItrHit=testItrHit-recItrHit;
    extraRecItrHit=diffItrHit==-1;
    extraTestItrHit=diffItrHit==1;
    reIdx=find(extraRecItrHit>0);
    teIdx=find(extraTestItrHit>0);
    
    % 对推荐集额外兴趣的分析
    extraRecItrHitNumRate=recItrHitNumRate(reIdx);
    sumExRecItrHitNumRate=sum(extraRecItrHitNumRate);
       
    % 对测试集额外兴趣的分析
    extraTestItrHitNumRate=testItrHitNumRate(teIdx);
    sumExTestItrHitNumRate=sum(extraTestItrHitNumRate);
    
    totalExRecItrHitNumRate=totalExRecItrHitNumRate+sumExRecItrHitNumRate;
    totalExTestItrHitNumRate=totalExTestItrHitNumRate+sumExTestItrHitNumRate;

    levelIdx=find(userLevel(:,1)==user);
    if isempty(levelIdx)
        level=0;
    else
        level=userLevel(levelIdx,2);
    end    
    allUserRecTestItr(i,:)=[user,sumExRecItrHitNumRate,sumExTestItrHitNumRate,level];       
    theCount=theCount+1;
end

levelNum=length(unique(userLevel(:,2)));
avgUserRecTestItrByLevel=zeros(levelNum,3);
for i=1:size(avgUserRecTestItrByLevel,1)
    
    level=i;
    idx=find(allUserRecTestItr(:,4)==level);
    avgExRecItrHitNumRateByLevel=sum(allUserRecTestItr(idx,2))/length(idx);
    avgExTestItrHitNumRateByLevel=sum(allUserRecTestItr(idx,3))/length(idx);
    
    avgUserRecTestItrByLevel(i,1)=level;
    avgUserRecTestItrByLevel(i,2)=avgExRecItrHitNumRateByLevel;
    avgUserRecTestItrByLevel(i,3)=avgExTestItrHitNumRateByLevel;   
end

avgExRecItrHitNumRate=totalExRecItrHitNumRate/theCount;
avgExTestItrHitNumRate=totalExTestItrHitNumRate/theCount;

avgExRecTestItrRate=[avgExRecItrHitNumRate,avgExTestItrHitNumRate];




end