function [avgUserItrCoverRate,avgUserItrCoverRateByLevel]=InterestCoverAnalysis(allUserFinalRecList,testSet,uniqItemData,likeThreshold,itemClassIndex,interestCount,userLevel)

% 分析各个Level用户的推荐结果对于测试集中兴趣的cover情况


theCount=0;

userCount=length(allUserFinalRecList);
allUserItrCoverRate=ones(length(userCount),3)*(-100);
totalUserItrCoverRate = 0;
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
    testItrHitNum = GetItemInterest(testUserLikedItemList,itemClassIndex,interestCount);
    testItrHitNumRate = testItrHitNum/sum(testItrHitNum);
    testItrHit = testItrHitNumRate>0;
      
    combinedItrHit = testItrHit + recItrHit;
    commonItrHit = combinedItrHit==2;
    commonItrNum = sum(commonItrHit);
    
    interestCoverRate = commonItrNum/ sum(testItrHit);
    totalUserItrCoverRate = totalUserItrCoverRate + interestCoverRate;
    
    levelIdx=find(userLevel(:,1)==user);
    if isempty(levelIdx)
        level=0;
    else
        level=userLevel(levelIdx,2);
    end    
    allUserItrCoverRate(i,:)=[user,interestCoverRate,level];       
    theCount=theCount+1;
end

levelNum=length(unique(userLevel(:,2)));
avgUserItrCoverRateByLevel=zeros(levelNum,2);
for i=1:levelNum
    level=i;
    idx=find(allUserItrCoverRate(:,3)==level);
    tempAvgCoverRate=sum(allUserItrCoverRate(idx,2))/length(idx);
    avgUserItrCoverRateByLevel(i,1)=level;
    avgUserItrCoverRateByLevel(i,2)=tempAvgCoverRate;
end

avgUserItrCoverRate=totalUserItrCoverRate/theCount;

end