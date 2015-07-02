function avgUserItrHitNumRateByLevel=HitInterestAnalysis(allUserInterestSet,testUserCount,userLevel)

% 专属于我自己的算法的分析
% 主要分析命中的item所属的兴趣中，哪些属于评分兴趣，哪些属于社交兴趣


allUserInterestHitNumRate=ones(testUserCount,7)*(-1);
% 分析用户的兴趣命中数比例
% 1评分  2社交  3重合  4评分额外  5社交额外  6每个兴趣的命中数  7 user 
for n=1:length(allUserInterestSet)
    userInterestSet=allUserInterestSet{n};
    if isempty(userInterestSet)
        continue
    end    
    user=unique(userInterestSet(:,7));    
    levelIdx=find(userLevel(:,1)==user);
    if isempty(levelIdx)
        level=0;
    else
        level=userLevel(levelIdx,2);
    end    
    
    interestHit=userInterestSet(:,6);    
    totalHitNum=sum(interestHit);
    
    if totalHitNum==0
        continue
    end
    
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
    
    allUserInterestHitNumRate(n,:)=[user,rhCoverNumRate,shCoverNumRate,ohCoverNumRate,rehCoverNumRate,sehCoverNumRate,level];
   
end

allUserInterestHitNumRate=sortrows(allUserInterestHitNumRate,7);
levelNum=length(unique(userLevel(:,2)));
avgUserItrHitNumRateByLevel=zeros(levelNum,6);
for i=1:size(avgUserItrHitNumRateByLevel,1)
    
    level=i;
    idx=find(allUserInterestHitNumRate(:,7)==level);
    avgRhCoverNumRate=sum(allUserInterestHitNumRate(idx,2))/length(idx);
    avgShCoverNumRate=sum(allUserInterestHitNumRate(idx,3))/length(idx);
    avgOhCoverNumRate=sum(allUserInterestHitNumRate(idx,4))/length(idx);
    avgRehCoverNumRate=sum(allUserInterestHitNumRate(idx,5))/length(idx);
    avgSehCoverNumRate=sum(allUserInterestHitNumRate(idx,6))/length(idx);
    
    avgUserItrHitNumRateByLevel(i,1)=level;
    avgUserItrHitNumRateByLevel(i,2)=avgRhCoverNumRate;
    avgUserItrHitNumRateByLevel(i,3)=avgShCoverNumRate;
    avgUserItrHitNumRateByLevel(i,4)=avgOhCoverNumRate;
    avgUserItrHitNumRateByLevel(i,5)=avgRehCoverNumRate;
    avgUserItrHitNumRateByLevel(i,6)=avgSehCoverNumRate;
  
end





end