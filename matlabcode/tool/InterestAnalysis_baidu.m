clear;
clc;
tic;

% �û���Ȥ�ֲ��ķ���

version=1;
width=10;height=10;
date='6.24';

totalSetFileName='..\\..\\..\\data\\baidu\\commondata\\finalRating.txt';
trainSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\trainSet%d.txt',version);
testSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\testSet%d.txt',version);
lessUserFileName='..\\..\\..\\data\\baidu\\commondata\\lessUserID.txt';
moreUserFileName='..\\..\\..\\data\\baidu\\commondata\\moreUserID.txt';
ratingSomFileName=sprintf('..\\..\\..\\data\\baidu\\somdata\\baidu_%dx%d_som%d.mat',width,height,version); 
resultFileName=sprintf('baidu_itr_result_%d_%s.txt',version,date);

likeThreshold=4;   % �ж��û��Ƿ�ϲ��һ��item����ֵ��Ҫ���ڵ�����

trainSet= load(trainSetFileName);
testSet= load(testSetFileName);
totalSet= load(totalSetFileName);

load(ratingSomFileName, 'weight','itemClassIndex');
lessUserID=load(lessUserFileName);
moreUserID=load(moreUserFileName);

userData=trainSet(:,1);
itemData=trainSet(:,2);
uniqUserData=unique(userData);
uniqItemData=unique(itemData);
userCount=length(uniqUserData);
itemCount=length(uniqItemData);

testUserData=testSet(:,1);
uniqTestUserData=unique(testUserData);
testUserCount=length(uniqTestUserData);

interestCount=size(weight,1);

totalExTrainItrHitNumRate=0;
totalExTrainItrHitRate=0;
totalExTestItrHitNumRate=0;
totalExTestItrHitRate=0;

lessTotalExTrainItrHitNumRate=0;
lessTotalExTrainItrHitRate=0;
lessTotalExTestItrHitNumRate=0;
lessTotalExTestItrHitRate=0;

moreTotalExTrainItrHitNumRate=0;
moreTotalExTrainItrHitRate=0;
moreTotalExTestItrHitNumRate=0;
moreTotalExTestItrHitRate=0;

totalCount=0;
lessTotalCount=0;
moreTotalCount=0;

allTotalItrCoverRate=0;
lessTotalItrCoverRate=0;
moreTotalItrCoverRate=0;

diffCount=0;
totalTrainExtraItrRate=0;
totalTrainWeightExtraItrRate=0;

parfor i=1:testUserCount
% for i=1000

    the20num=round(0.2*testUserCount);
    if mod(i,the20num)==0
        disp ('20%');
    end

     % ���Ƽ��û�ID
    testUser=uniqTestUserData(i);
    % ��ѵ�����е�uniqUserData�� testuser��Ӧ��ID
    testUserID=find(uniqUserData==testUser);
   
    % ѵ��������ص�item
    trainIndex=find(trainSet(:,1)==testUser & trainSet(:,3)>=likeThreshold);
    trainItem=trainSet(trainIndex,2);  
    if isempty(trainItem)
        continue
    end
    [~,IA1,~]=intersect(uniqItemData,trainItem);
    trainItemList=IA1;
    
    % ���Լ�����ص�item    
    testIndex=find(testSet(:,1)==testUser & testSet(:,3)>=likeThreshold);
    testItem=testSet(testIndex,2);  
    if isempty(testItem)
        continue
    end
    [~,IA2,~]=intersect(uniqItemData,testItem);
    testItemList=IA2;
    
    % �������ݼ�����ص�item
    totalIndex=find(totalSet(:,1)==testUser & totalSet(:,3)>=likeThreshold);
    totalItem=totalSet(totalIndex,2);   
    [~,IA3,~]=intersect(uniqItemData,totalItem);
    totalItemList=IA3;
          
    % ����ѵ��������Ȥ�ķֲ�������ÿ����Ȥ��������
    trainItrHitNum=GetItemInterest(trainItemList,itemClassIndex,interestCount);
    trainItrHitNumRate=trainItrHitNum/sum(trainItrHitNum);
    trainItrHit=trainItrHitNumRate>0;
    trainItrHitRate=trainItrHit/sum(trainItrHit);
    
    % �������Լ�����Ȥ�ķֲ�
    testItrHitNum=GetItemInterest(testItemList,itemClassIndex,interestCount);
    testItrHitNumRate=testItrHitNum/sum(testItrHitNum);
    testItrHit=testItrHitNumRate>0;
    testItrHitRate=testItrHit/sum(testItrHit);
    
    diffItrHit=testItrHit-trainItrHit;
    extraTrainItrHit=diffItrHit==-1;
    extraTestItrHit=diffItrHit==1;
    trIdx=find(extraTrainItrHit>0);
    teIdx=find(extraTestItrHit>0);
    
    % ��ѵ����������Ȥ�ķ���
    extraTrainItrHitNumRate=trainItrHitNumRate(trIdx);
    extraTrainItrHitRate=trainItrHitRate(trIdx);
    sumExTrainItrHitNumRate=sum(extraTrainItrHitNumRate);
    sumExTrainItrHitRate=sum(extraTrainItrHitRate);
       
    % �Բ��Լ�������Ȥ�ķ���
    extraTestItrHitNumRate=testItrHitNumRate(teIdx);
    extraTestItrHitRate=testItrHitRate(teIdx);
    sumExTestItrHitNumRate=sum(extraTestItrHitNumRate);
    sumExTestItrHitRate=sum(extraTestItrHitRate);
    
    totalExTrainItrHitNumRate=totalExTrainItrHitNumRate+sumExTrainItrHitNumRate;
    totalExTrainItrHitRate=totalExTrainItrHitRate+sumExTrainItrHitRate;
    totalExTestItrHitNumRate=totalExTestItrHitNumRate+sumExTestItrHitNumRate;
    totalExTestItrHitRate=totalExTestItrHitRate+sumExTestItrHitRate;
    
    idx=intersect(lessUserID,testUser);
    
     % �����������ݼ�����Ȥ�ĸ������
     totalItrHitNum=GetItemInterest(totalItemList,itemClassIndex,interestCount);
     totalItrHit=totalItrHitNum>0;
     totalItrCover=sum(totalItrHit)/interestCount;
        
    allTotalItrCoverRate=allTotalItrCoverRate+totalItrCover;
       
    if ~isempty(idx)         
        lessTotalExTrainItrHitNumRate=lessTotalExTrainItrHitNumRate+sumExTrainItrHitNumRate;
        lessTotalExTrainItrHitRate=lessTotalExTrainItrHitRate+sumExTrainItrHitRate;
        lessTotalExTestItrHitNumRate=lessTotalExTestItrHitNumRate+sumExTestItrHitNumRate;
        lessTotalExTestItrHitRate=lessTotalExTestItrHitRate+sumExTestItrHitRate;
        lessTotalItrCoverRate=lessTotalItrCoverRate+totalItrCover;
        lessTotalCount=lessTotalCount+1;
    else    
        moreTotalExTrainItrHitNumRate=moreTotalExTrainItrHitNumRate+sumExTrainItrHitNumRate;
        moreTotalExTrainItrHitRate=moreTotalExTrainItrHitRate+sumExTrainItrHitRate;
        moreTotalExTestItrHitNumRate=moreTotalExTestItrHitNumRate+sumExTestItrHitNumRate;
        moreTotalExTestItrHitRate=moreTotalExTestItrHitRate+sumExTestItrHitRate;
        moreTotalItrCoverRate=moreTotalItrCoverRate+totalItrCover;
        moreTotalCount=moreTotalCount+1;
    end
     
    % �Ƚ�ͨ��ѵ�������ֵ���Ȥ��ͨ��SOM����õ�����Ȥ֮��Ĳ���
    
    trainItrHitByWeight=weight(:,testUserID);
    trainItrHitByWeight=trainItrHitByWeight>0.05;   
    if sum(trainItrHitByWeight)==0
        continue
    end
    trainItrHitDiff=trainItrHit-trainItrHitByWeight;
    trainExtraItrIdx=find(trainItrHitDiff==1);
    trainWeightExtraItrIdx=find(trainItrHitDiff==-1);
    trainExtraItrRate=length(trainExtraItrIdx)/sum(trainItrHit);
    trainWeightExtraItrRate=length(trainWeightExtraItrIdx)/sum(trainItrHitByWeight);
    
    totalTrainExtraItrRate=totalTrainExtraItrRate+trainExtraItrRate;
    totalTrainWeightExtraItrRate=totalTrainWeightExtraItrRate+trainWeightExtraItrRate;
   
    
    
    totalCount=totalCount+1;
   
    
end
    
avgTrainExtraItrRate=totalTrainExtraItrRate/totalCount;
avgTrainWeightExtraItrRate=totalTrainWeightExtraItrRate/totalCount;


avgExTrainItrHitNumRate=totalExTrainItrHitNumRate/totalCount;
avgExTrainItrHitRate=totalExTrainItrHitRate/totalCount;
avgExTestItrHitNumRate=totalExTestItrHitNumRate/totalCount;
avgExTestItrHitRate=totalExTestItrHitRate/totalCount;

lessAvgExTrainItrHitNumRate=lessTotalExTrainItrHitNumRate/lessTotalCount;
lessAvgExTrainItrHitRate=lessTotalExTrainItrHitRate/lessTotalCount;
lessAvgExTestItrHitNumRate=lessTotalExTestItrHitNumRate/lessTotalCount;
lessAvgExTestItrHitRate=lessTotalExTestItrHitRate/lessTotalCount;


moreAvgExTrainItrHitNumRate=moreTotalExTrainItrHitNumRate/moreTotalCount;
moreAvgExTrainItrHitRate=moreTotalExTrainItrHitRate/moreTotalCount;
moreAvgExTestItrHitNumRate=moreTotalExTestItrHitNumRate/moreTotalCount;
moreAvgExTestItrHitRate=moreTotalExTestItrHitRate/moreTotalCount;


avgAllTotalItrCoverRate=allTotalItrCoverRate/totalCount;
avgLessTotalItrCoverRate=lessTotalItrCoverRate/lessTotalCount;
avgMoreTotalItrCoverRate=moreTotalItrCoverRate/moreTotalCount;


fid = fopen(resultFileName,'a');
fprintf(fid,'--------------------------- total ----------------------------------\r\n');
fprintf(fid,'the avgExTrainItrHitNumRate is %f, the avgExTrainItrHitRate is %f, the avgExTestItrHitNumRate is %f ,the avgExTestItrHitRate is %f \r\n',avgExTrainItrHitNumRate,avgExTrainItrHitRate,avgExTestItrHitNumRate,avgExTestItrHitRate);

fprintf(fid,'--------------------------  less user ------------------------------\r\n');
fprintf(fid,'the lessAvgExTrainItrHitNumRate is %f, the lessAvgExTrainItrHitRate is %f, the lessAvgExTestItrHitNumRate is %f ,the lessAvgExTestItrHitRate is %f \r\n',lessAvgExTrainItrHitNumRate,lessAvgExTrainItrHitRate,lessAvgExTestItrHitNumRate,lessAvgExTestItrHitRate);

fprintf(fid,'--------------------------  more user ------------------------------\r\n');
fprintf(fid,'the moreAvgExTrainItrHitNumRate is %f, the moreAvgExTrainItrHitRate is %f, the moreAvgExTestItrHitNumRate is %f ,the moreAvgExTestItrHitRate is %f \r\n',moreAvgExTrainItrHitNumRate,moreAvgExTrainItrHitRate,moreAvgExTestItrHitNumRate,moreAvgExTestItrHitRate);

fprintf(fid,'the totalCount is %d \r\n',totalCount);
fprintf(fid,'--------------------- cutoff line ----------------------- \r\n\r\n');
fclose(fid);




toc;