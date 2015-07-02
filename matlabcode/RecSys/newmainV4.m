clear;
tic;

%% ���һ��������



fprintf('ֻ��δ����������Ȥ + 5�罻���� +recThreshold =0 + som 10 x 10  \n');
%% **************���ļ�����ʹ洢��Ŀ¼���������趨*********************************
date='8.26';
version=1;   % �ڼ������ݼ�
width=10;height=10;

ratingSomFileName=sprintf('..\\..\\..\\data\\baidu\\somdata\\baidu_%dx%d_som%d.mat',width,height,version); 
testSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\testSet%d.txt',version);
resultFileName=sprintf('..\\..\\..\\result\\baidu\\som\\baidu_som_result_%d_%s.txt',version,date);
% itemSimiFileName=sprintf('..\\..\\..\\data\\baidu\\ibcfdata\\itemSimiMatrix%d.mat',version);
userLevelFileName='..\\..\\..\\data\\baidu\\commondata\\userLevel.txt';
saveRecListFileName=sprintf('..\\..\\..\\data\\baidu\\somdata\\recList\\reclist%d.mat',version);
weightFileName = sprintf('..\\..\\..\\data\\baidu\\commondata\\weight_%dx%d.mat',width,height);
userRatingMatrixFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\userRatingMatrix%d.mat',version);
socialTrustFileName='..\\..\\..\\data\\baidu\\commondata\\friendList.txt';
% ###
userSocialTrustCellFileName='..\\..\\..\\data\\baidu\\commondata\\userSocialTrustCell.mat';
% ###

%% ********************����֮ǰ�����õ�����**********************************

load(ratingSomFileName, 'uniqUserData', 'uniqItemData', 'itemClassIndex');
load(userRatingMatrixFileName);
%  userRatingMatrix=full(userRatingMatrix);   % spase ת full
testSet= load(testSetFileName);
socialTrustData=load(socialTrustFileName);
% load(itemSimiFileName,'itemSimiMatrix');
userLevel=load(userLevelFileName);

% ###
% load(userSocialTrustCellFileName);
% ###

format long;

% weight = CalculateWeight(userRatingMatrix, itemClassIndex, width, height);
% save(weightFileName,'weight');
load(weightFileName);

%% ******************���г�ʼ��***************************

userCount=length(uniqUserData);
itemCount=length(uniqItemData);
testUserData=testSet(:,1);
uniqTestUserData=unique(testUserData);
testUserCount=length(uniqTestUserData);
interestCount=size(weight,1);
levelNum=length(unique(userLevel(:,2)));

% һЩ��Ϊ�̶��Ĳ���
likeThreshold=4;   % �ж��û��Ƿ�ϲ��һ��item����ֵ��Ҫ������
recThreshold=0;  % ����������Ȥ�����Ƽ�ʱ����ÿ����ȤȦ�Ԥ������Ҫ���������ֵ�Żᱻ�Ƽ�
alpha=0.5; % ��Ȥ�ϲ��Ĳ�����rating=alpha��social=1-alpha
interestCircleThreshold=0.3;  %������Ȥ�û�����ֵ���������ֵ���û����뵽��ȤȦ
majorInterestThreshold=0.00; % �����Ƿ�����Ҫ��Ȥ

ratingNumThreshold=20;

% % ȡ���û���trust�б�
userSocialTrustCell=GetUserSocialTrust(uniqUserData,socialTrustData);


% % �������û����ֵ���ͬ��Ȥ����ȥ����ͬ��֮���û������ص�
userInterestCircleCell=SplitUserByInterestCircle(weight,interestCircleThreshold);

% �������û����ֵ���ͬ��Ȥ����ȥ����ͬ��֮���û������ص�
% userInterestCircleCell=SplitUserByInterestCircle2(weight,userRatingMatrix,itemClassIndex,ratingNumThreshold);


% ������item���ֵ���ͬ��Ȥ���У���֮��item���ص�
itemInterestCircleCell=SplitItemByInterestCircle(itemClassIndex,interestCount);

% ��������û�ƽ�����
userAvgRating=GetAllUserAvgRating(userRatingMatrix);

%% **** ��������� *******
% topKList=(10:10:100);
% socialNeighbourNumList=(10:10:100);
% for iter1=1:length(topKList)
% topK=topKList(iter1);
% for iter2=1:length(socialNeighbourNumList)
% socialNeighbourNum=socialNeighbourNumList(iter2);
%% ***************�������ü�һЩ��ʼ������*********************
topK=100;           % �����Ƽ��б�ǰtopK��
socialNeighbourNum=5 ; % social friend ���������ٸ�

recListLengthRecord=[]; % ��¼һ��ÿ���û����Ƽ��б�ĳ��ȣ��������topK

% ��¼��ÿ���û����Ƽ��б�
allUserFinalRecList=cell(testUserCount,1);  
% ��¼�����û�������ָ����
allUserEvaluation=ones(length(testUserCount),4)*(-100);
% ��¼ÿ���û�����Ȥ
allUserInterestSet=cell(testUserCount,1);

totalPrecision=0; totalRecall=0; 
%��Ϊ������precision,recall ,f1�ķ�ĸ
totalCount=0;

fprintf('start the iteration ...')
specialCount1=0;   % level 1 user num
specialCount2=0;   % ����Ȥ���û�num
specialCount3=0;   % ���Ƽ����û�num
specialCount4=0;   % �в��Լ����û�num
specialCount5=0;
specialCount6=0;
totalAvgHitRank=0;
totalClassNum=0;

totalSpecialRank=0;
specialRankVector=[];
specialRankCount=0;
allUserItrHitRecord=[];

%% *******************��ʼ����************************
parfor i=1:testUserCount
% for i=6
%     disp(i);
    the20num=round(0.2*testUserCount);
    if mod(i,the20num)==0
        disp ('20%');
    end
    %% ***********��ÿ��Ŀ���û�����һЩ��ʼ��****************
    
    % ���Ƽ��û�ID
    testUser=uniqTestUserData(i);
    % ��ѵ�����е�uniqUserData�� testuser��Ӧ��ID
    testUserID=find(uniqUserData==testUser);
    

%     tempIdx=find(userLevel(:,1)==testUser);
%     tempLevel=userLevel(tempIdx,2);
%     if tempLevel==1
%         continue;
%     end
%     specialCount1 = specialCount1+1;

    %% *********************************������һ����ȡ��Ŀ���û����Ƽ��б�*********************
    
    %% ***********ȡ��Ŀ���û�����������Ϣ�õ�����Ȥ��Ȩ��************
    
    ratingInterestWeight=zeros(interestCount,2);
    ratingInterestWeight(:,1)=(1:interestCount);
    ratingInterestWeight(:,2)=weight(:,testUserID);
   
    % ѡ�������ֵ����Ȥ,�����Ĳ�ȥ����ֻ�Ǹ�ֵΪ0�����������
    % ########### rating interest ��ʱ������########################
%     idx=find(ratingInterestWeight(:,2) < majorInterestThreshold);
%     ratingInterestWeight(idx,2)=0;

    % ��һ��
    totalWeight1 = sum(ratingInterestWeight(:,2));
    if totalWeight1>0
        ratingInterestWeight(:,2)=ratingInterestWeight(:,2)/totalWeight1;
    end
    
    %% ***********ȡ��Ŀ���û������罻��Ϣ�õ�����Ȥ��Ȩ��*************
    
    userSocialCircle=userSocialTrustCell{testUserID};
    
    if isempty(userSocialCircle)
        socialInterestWeight=zeros(interestCount,2);
    else
        socialFriendNum = size(userSocialCircle,1);
        if socialFriendNum>socialNeighbourNum
           realSocialNeiNum = socialNeighbourNum;
        else
           realSocialNeiNum=socialFriendNum;
        end
        userSocialCircle=userSocialCircle(1:realSocialNeiNum,:);
        socialInterestWeight=GetSocialInterestWeight(userSocialCircle,weight,majorInterestThreshold);
        % ��һ��
        totalWeight2=sum(socialInterestWeight(:,2));
        if totalWeight2>0
            socialInterestWeight(:,2)=socialInterestWeight(:,2)/totalWeight2;
        end
    end
    
    %% ***************��Ȥ�ϲ�*************************
    mixedInterestWeight=zeros(interestCount,2);
    mixedInterestWeight(:,1)=(1:interestCount);
    mixedInterestWeight(:,2)=alpha*ratingInterestWeight(:,2)+(1-alpha)*socialInterestWeight(:,2);
%     mixedInterestWeight(:,2)=ratingInterestWeight(:,2);

    % ȥ��Ϊ0����Ȥ
    tx0=find(mixedInterestWeight(:,2)>0);
    mixedInterestWeight=mixedInterestWeight(tx0,:);
    % ��������
    mixedInterestWeight=-sortrows(-mixedInterestWeight,2);     
    
    if isempty(mixedInterestWeight)
        continue
    end
    specialCount2 =specialCount2 +1 ;
      
    
    % ��������Ȩ�صĺ�
    totalWeight=sum(mixedInterestWeight(:,2));
    totalInterestRecList=[];
        
    % �����ִ���likeThreshold��ʾϲ��
    tempIndex=find(testSet(:,1)==testUser & testSet(:,3)>=likeThreshold);
    tempItemSet=testSet(tempIndex,2);
    
    [commonItem,IA,IB]=intersect(uniqItemData,tempItemSet);
    testUserLikedItemList=IA;
        
    if isempty(testUserLikedItemList)
        % ���Լ��û���û�����ִ���3��item���򲻿�������û����Ƽ��������Ƽ�
        specialCount3=specialCount3+1;
        continue;
    end
%     
  
    %% ************* ����Ŀ���û�ÿһ����Ȥ����һ���Ƽ��б���ȥ���û��Ѿ������� *********************
    for j=1:size(mixedInterestWeight,1)
        
        % �����Ȩ��,����ٺϲ�����Ȥ���ϣ�Ҫ����ȥ
        tempWeight=mixedInterestWeight(j,2)/totalWeight;
        % ��ȡ�ڸ���ȤȦ�������
        userInterestCircle=userInterestCircleCell{mixedInterestWeight(j,1)};
        % ע����ȤȦΪ�յ����
        if isempty(userInterestCircle)
            continue
        end
        % ����ȤС����ȥ���Լ�
        idx1=find(userInterestCircle(:,1)==testUserID);
        userInterestCircle(idx1,:)=[];
        % ��ȡ���ֵ�����ȤȦ��item
        itemInterestCircle=itemInterestCircleCell{mixedInterestWeight(j,1)};
        if isempty(itemInterestCircle)
            continue
        end
        % *****������Ȥ�����Ƽ�******     
        interestRecList=GetRecListByInterestCircle(testUserID,userInterestCircle,itemInterestCircle,userRatingMatrix,recThreshold,userAvgRating);
        
        
         [hitList,iia,iib]=intersect(interestRecList(:,1),testUserLikedItemList);
        
        % ��2�׷����������⣬��ʱ��ʹ��
        %interestRecList=GetRecListByInterestCircle2(testUserID,userInterestCircle,itemInterestCircle,userRatingMatrix,recThreshold,userAvgRating);
             
        % ����Ҫ�������Ȧ�ӵ����Ȩ��
        interestRecList(:,2)=interestRecList(:,2)*tempWeight;
       
%         interestRecList(:,2)=3*interestRecList(:,2)*tempWeight./(interestRecList(:,2)+2*tempWeight);
        
        % �����һ����ע������item��������Ȥ���ID����ʱ���ٸĻ���
        completeInterestRecList=zeros(size(interestRecList,1),3);
        completeInterestRecList(:,1:2)=interestRecList;
        completeInterestRecList(:,3)=mixedInterestWeight(j,1);
        % ���ܸ�����ȤȦ�ӵĽ��
        %         totalInterestRecList=[totalInterestRecList;interestRecList];
        totalInterestRecList=[totalInterestRecList; completeInterestRecList];
    end   
    
    if isempty(totalInterestRecList)
        continue
    end
    
    
    % �Ժϲ�����Ƽ��б���ָߵͽ������򣬽�������
    totalInterestRecList=-sortrows(-totalInterestRecList,2);
    
    % ȥ��testUser�Ѿ�������
    watchedItemList=find(userRatingMatrix(testUserID,:)>0);
    [c,ia]=intersect(totalInterestRecList(:,1),watchedItemList);
    totalInterestRecList(ia,:)=[];
    
    if isempty(totalInterestRecList)
       
        continue
    end
    specialCount3 = specialCount3+1;
    
    % ��¼һ��ÿ���û����Ƽ��б�ĳ��ȣ��������topK
    if size(totalInterestRecList,1)>0
        recListLengthRecord=[recListLengthRecord; [testUser size(totalInterestRecList,1)]];
    end
      
    
    % ��topK�����ã������Ͳ�����
    if length(totalInterestRecList(:,1))<topK
        realTopK=length(totalInterestRecList(:,1));
        finalRecList=totalInterestRecList(1:realTopK,1);
%         diverseClassNum=length(unique(totalInterestRecList(1:realTopK,3)));
    else
        finalRecList=totalInterestRecList(1:topK,1);
%         diverseClassNum=length(unique(totalInterestRecList(1:topK,3)));
    end
    
    if isempty(finalRecList)
 
        continue;
    end
 
    %% **********************************�����ڶ�����ȡ�ò��Լ���Ŀ���û�ϲ����item�б�***********************
    % �����ִ���likeThreshold��ʾϲ��
    tempIndex=find(testSet(:,1)==testUser & testSet(:,3)>=likeThreshold);
    tempItemSet=testSet(tempIndex,2);
    
    [commonItem,IA,IB]=intersect(uniqItemData,tempItemSet);
    testUserLikedItemList=IA;
        
    if isempty(testUserLikedItemList)
        % ���Լ��û���û�����ִ���3��item���򲻿�������û����Ƽ��������Ƽ�
        specialCount3=specialCount3+1;
        continue;
    end
    
    %% **************************************�����������������Ƽ�Ч��****************************************
    % ���Ƽ��б�Ͳ��Լ����û�ϲ����itemȡ��������Ϊhit����
    [hitList,iia,iib]=intersect(finalRecList,testUserLikedItemList);
    if ~isempty(hitList)
        tempAvgHitRank=sum(iia)/length(iia);
        totalAvgHitRank=totalAvgHitRank+tempAvgHitRank;
    end
    if isempty(finalRecList) || isempty(testUserLikedItemList)
        disp('there is something wrong with the finalRecList or the testUserLikedItemList');
        continue;
    end
    % ���㵥���û���precision��recall
    precision=length(hitList)/length(finalRecList);
    recall=length(hitList)/length(testUserLikedItemList);
    if isnan(recall) || isnan(precision)
        disp('there is something wrong with the recall or the precision');
    end
    totalPrecision=totalPrecision+precision;
    totalRecall=totalRecall+recall;  
    
%     % ����һЩ��Ȥ������������Ҫ��
%     userInterestSet=zeros(interestCount,7);
%     userInterestSet(:,1)= ratingInterestWeight(:,2)>0;  %������Ȥ
%     userInterestSet(:,2)= socialInterestWeight(:,2)>0;  %�罻��Ȥ
%     combineInterest= userInterestSet(:,1)+userInterestSet(:,2);
%     userInterestSet(:,3)=combineInterest==2 ;          % �������罻�غ���Ȥ
%     extraInterest= userInterestSet(:,2)-userInterestSet(:,1);
%     userInterestSet(:,4)= extraInterest==-1 ;  %���ֵĶ�����Ȥ
%     userInterestSet(:,5)= extraInterest==1;    %�罻�Ķ�����Ȥ;
%     
%     %����hitList��������Ȥ
%     interestHit=GetItemInterest(hitList,itemClassIndex,interestCount);
%     userInterestSet(:,6)=interestHit;
%     userInterestSet(:,7)=testUser;
%     allUserInterestSet{i}=userInterestSet;
%        
    levelIdx=find(userLevel(:,1)==testUser);
    if isempty(levelIdx)
        level=0;
    else
        level=userLevel(levelIdx,2);
    end
    allUserEvaluation(i,:)=[testUser,precision,recall,level];
        
    % ��¼ÿ���û������յ��Ƽ��б�
    recListCell=cell(1,2);
    recListCell{1}=testUser;
    recListCell{2}=finalRecList;
    allUserFinalRecList{i}=recListCell;
       
    testLen = length(testUserLikedItemList);
    hitLen = length(hitList);
    avgClassRank =-9999;
    totalClassRank = 0;
    itrHitNum=0;
    classNum = size(mixedInterestWeight,1);
    wholeList = [];
    for m =1:testLen
        item = testUserLikedItemList(m);
        class = itemClassIndex(item);
        classRank = find(mixedInterestWeight(:,1) == class);
        if ~isempty(classRank)
            itrHitNum =itrHitNum+1;
            totalClassRank =totalClassRank+classRank;
            wholeList=[wholeList;item];
        end
    end
    if itrHitNum~=0
        avgClassRank = totalClassRank/itrHitNum;
    end
    avgHitRank=-999;
    avgNoHitRank=-999;
    hitNum=-999;
    noHitNum=-999;
    [list1,idxa,idxb]=intersect(totalInterestRecList(:,1),hitList);
    if ~isempty(list1)
        hitNum = length(list1);
        avgHitRank=sum(idxa)/length(idxa);
    end
    otherList = setdiff(wholeList,hitList);
    [list2,idxa,idxb]=intersect(totalInterestRecList(:,1),otherList);
    if ~isempty(list2)
        noHitNum =length(list2);
        avgNoHitRank=sum(idxa)/length(idxa);
    end
    
    allUserItrHitRecord = [allUserItrHitRecord ; [level,testUserID,avgClassRank,classNum,hitLen,itrHitNum, testLen,hitNum,avgHitRank,noHitNum,avgNoHitRank ]];
    
    
%     totalClassNum=totalClassNum+diverseClassNum;
    % �ܵ����ģ�����+1�������Ϊ��ĸ
    totalCount=totalCount+1;
    
    
end

%% #####################����ָ��###########################
avgRealHitRate = sum(allUserItrHitRecord(:,5)./allUserItrHitRecord(:,7))/size(allUserItrHitRecord,1);
avgItrHitRate = sum(allUserItrHitRecord(:,6)./allUserItrHitRecord(:,7))/size(allUserItrHitRecord,1);
idx =find(allUserItrHitRecord(:,6)>0);
avgClassPosi = sum(allUserItrHitRecord(idx,3)./allUserItrHitRecord(idx,4))/length(idx);

idx1=find(allUserItrHitRecord(:,9)>0);
hitPos = sum(allUserItrHitRecord(idx1,9))/length(idx1);

idx2 = find(allUserItrHitRecord(:,11)>0);
noHitPos = sum(allUserItrHitRecord(idx2,11))/length(idx2);


%����������Level�û��� ׼ȷ�� �ٻ��� F1
avgUserEvaluationByLevel=EvaluationAnalysis(allUserEvaluation,levelNum);

% ��������Level�û��Ƽ����Ͳ��Լ�֮�����Ȥ�ĸ��ǹ�ϵ
% [avgUserRecTestItrByLevel,avgExRecTestItrRate]=RecTestSetInterestAnalysis(allUserFinalRecList,testSet,uniqItemData,likeThreshold,itemClassIndex,interestCount,userLevel);
% avgExRecItrHitNumRate=avgExRecTestItrRate(1);
% avgExTestItrHitNumRate=avgExRecTestItrRate(2);

% �������е�item��������Ȥ�У���Щ����������Ȥ����Щ�����罻��Ȥ
% avgUserItrHitNumRateByLevel=HitInterestAnalysis(allUserInterestSet,testUserCount,userLevel);

avgPrecision=totalPrecision/totalCount;
avgRecall=totalRecall/totalCount;
avgF1=2*avgPrecision*avgRecall/(avgPrecision+avgRecall);
allRecListSet=[];

coverage=0;
avgILS=0;

% totalILS=0;
% acount=0;
% for i=1:testUserCount
%     recListCell=allUserFinalRecList{i};
%     if isempty(recListCell)
%         continue
%     end
%     recList=recListCell{2};
%     allRecListSet=[allRecListSet recList'];   
%     if length(recList)>1                   
%         tempILS=GetIntraListSimi(recList,itemSimiMatrix);
%         totalILS=totalILS+tempILS;   
%         acount=acount+1;       
%     end  
% end
% avgILS=totalILS/acount;  % ������
% uniqueAllRecListSet=unique(allRecListSet);
% coverage=length(uniqueAllRecListSet)/itemCount;  % ������

resultStr=sprintf('the avgPrecision is %f, the avgRecall is %f, avgF1 is %f, coverage is %f, average ILS is %f',avgPrecision,avgRecall,avgF1,coverage,avgILS);
disp(resultStr);
% ����topK���컨�壬�����ĸ�ֵ���Ͳ�����ȡ��
topKCeil= min(recListLengthRecord);

%% *************���������*****************

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

%�����Ƽ��б��Ա�֮����з���
% save(saveRecListFileName,'allUserFinalRecList');
% end
% end

toc;

