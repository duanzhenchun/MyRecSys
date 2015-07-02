function [avgUserRecTestItrByLevel,avgExRecTestItrRate]=RecTestSetInterestAnalysis(allUserFinalRecList,testSet,uniqItemData,likeThreshold,itemClassIndex,interestCount,userLevel)

% ��������Level�û��Ƽ����ϺͲ��Լ�������Ȥ�ķֲ����
% 1.�Ƽ����� �� ���Լ�����  item������Ȥ���� �� �غ� ���� ���
% 2.�Ƽ����� �� ���Լ�����  item��������

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
    
    %����recList��������Ȥ�ֲ������ص����ڸ�����Ȥ�����и���
    recItrHitNum=GetItemInterest(recList,itemClassIndex,interestCount);
    recItrHitNumRate=recItrHitNum/sum(recItrHitNum);
    recItrHit=recItrHitNumRate>0;
    
    %����testUserLikedItemList��������Ȥ�ֲ������ص����ڸ�����Ȥ�����и���
    testItrHitNum=GetItemInterest(testUserLikedItemList,itemClassIndex,interestCount);
    testItrHitNumRate=testItrHitNum/sum(testItrHitNum);
    testItrHit=testItrHitNumRate>0;
      
    diffItrHit=testItrHit-recItrHit;
    extraRecItrHit=diffItrHit==-1;
    extraTestItrHit=diffItrHit==1;
    reIdx=find(extraRecItrHit>0);
    teIdx=find(extraTestItrHit>0);
    
    % ���Ƽ���������Ȥ�ķ���
    extraRecItrHitNumRate=recItrHitNumRate(reIdx);
    sumExRecItrHitNumRate=sum(extraRecItrHitNumRate);
       
    % �Բ��Լ�������Ȥ�ķ���
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