clear;
tic;

%% ������ v2.0 ��
% �����û���Ȥ���Ƽ�
% �ֱ���������Ϣ���罻��Ϣ���ھ��û�����Ȥ
% �ҳ��û�����Ȥ���ٻ�����Ȥ���������Ƽ�

%% **************���ļ�����ʹ洢��Ŀ¼���������趨*********************************
date='6.25';
version=1;   % �ڼ������ݼ�
width=8;height=8;

ratingSomFileName=sprintf('..\\..\\..\\data\\baidu\\somdata\\baidu_%dx%d_som%d.mat',width,height,version); 
socialTrustFileName='..\\..\\..\\data\\baidu\\commondata\\trust200.txt';
testSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\testSet%d.txt',version);
resultFileName=sprintf('..\\..\\..\\result\\baidu\\som\\baidu_som_result_%d_%s.txt',version,date);
itemSimiFileName=sprintf('..\\..\\..\\data\\baidu\\ibcfdata\\itemSimiMatrix%d.mat',version);
lessUserFileName='..\\..\\..\\data\\baidu\\commondata\\lessUserID.txt';
moreUserFileName='..\\..\\..\\data\\baidu\\commondata\\moreUserID.txt';
saveAllDataFileName=sprintf('..\\..\\..\\data\\baidu\\somdata\\alldata\\all%d.mat',version);

%% ********************����֮ǰ�����õ�����**********************************

% ��������
load(ratingSomFileName, 'uniqUserData', 'uniqItemData', ...
    'userRatingMatrix','weight', 'itemClassIndex');
testSet= load(testSetFileName);
socialTrustData=load(socialTrustFileName);
load(itemSimiFileName,'itemSimiMatrix');
lessUserID=load(lessUserFileName);
moreUserID=load(moreUserFileName);

format long;

%% ******************���г�ʼ��***************************

userCount=length(uniqUserData);
itemCount=length(uniqItemData);
testUserData=testSet(:,1);
uniqTestUserData=unique(testUserData);
testUserCount=length(uniqTestUserData);
interestCount=size(weight,1);

% һЩ��Ϊ�̶��Ĳ���
likeThreshold=4;   % �ж��û��Ƿ�ϲ��һ��item����ֵ��Ҫ������
recThreshold=3;  % ����������Ȥ�����Ƽ�ʱ����ÿ����ȤȦ�Ԥ������Ҫ���������ֵ�Żᱻ�Ƽ�
alpha=0.5; % ��Ȥ�ϲ��Ĳ�����rating=alpha��social=1-alpha
interestCircleThreshold=0.2;  %������Ȥ�û�����ֵ���������ֵ����Ȥ���Գ�Ϊ������Ȥ�����뵽��ȤȦ
majorInterestThreshold=0.05; % �����Ƿ�����Ҫ��Ȥ

% ȡ���û���trust�б�
userSocialTrustCell=GetUserSocialTrust(uniqUserData,socialTrustData);

% ��������û�����ȤȨ�أ�������������
% allSortedWeightCell=GetAllSortedWeight(weight);

% �������û����ֵ���ͬ��Ȥ����ȥ����ͬ��֮���û������ص�
userInterestCircleCell=SplitUserByInterestCircle(weight,interestCircleThreshold);
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
topK=10;           % �����Ƽ��б�ǰtopK��
socialNeighbourNum=20;

recListLengthRecord=[]; % ��¼һ��ÿ���û����Ƽ��б�ĳ��ȣ��������topK
allUserFinalRecList=cell(testUserCount,1);   % ��¼��ÿ���û����Ƽ��б�
% ��¼�����û��Ľ��
allUserResult=ones(length(testUserCount),3)*(-1);
 %��¼ÿ���û�����Ȥ
allUserInterestSet=cell(testUserCount,1);

totalPrecision=0; totalRecall=0; 
%��Ϊ������precision,recall ,f1�ķ�ĸ
totalCount=0;

fprintf('start the iteration ...')
%% *******************��ʼ����************************
parfor i=1:testUserCount

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
        
    %% *********************************������һ����ȡ��Ŀ���û����Ƽ��б�*********************
    
    %% ***********ȡ��Ŀ���û�����������Ϣ�õ�����Ȥ��Ȩ��************
    
    ratingInterestWeight=zeros(interestCount,2);
    ratingInterestWeight(:,1)=(1:interestCount);
    ratingInterestWeight(:,2)=weight(:,testUserID);
   
    % ѡ�������ֵ����Ȥ,�����Ĳ�ȥ����ֻ�Ǹ�ֵΪ0�����������
    idx=find(ratingInterestWeight(:,2)<majorInterestThreshold);
    ratingInterestWeight(idx,2)=0;
    
    % ��ȫΪ0����û��Ҫ��һ��
    if length(idx)<interestCount
        % ��һ��
        totalWeight1=sum(ratingInterestWeight(:,2));
        ratingInterestWeight(:,2)=ratingInterestWeight(:,2)/totalWeight1;
    end
    
    %% ***********ȡ��Ŀ���û������罻��Ϣ�õ�����Ȥ��Ȩ��*************
    
    userSocialCircle=userSocialTrustCell{testUserID};
    userSocialCircle=userSocialCircle(1:socialNeighbourNum,:);
    socialInterestWeight=GetSocialInterestWeight(userSocialCircle,weight,majorInterestThreshold);
    % ��һ��
    totalWeight2=sum(socialInterestWeight(:,2));
    socialInterestWeight(:,2)=socialInterestWeight(:,2)/totalWeight2;
    
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
    
    %% ***********ȡ���û�ǰ�ٷ�֮M����Ȥ��Ȩ��*******************
    
%     %ȡǰ�ٷ�֮M����Ȥ����Ȩ��
%     totalInterestNum=size(mixedInterestWeight(:,1),1);
%     topInterestNum=ceil(topMInterestRate*totalInterestNum);
%     finalTopInterestNum=min(topInterestNum,totalInterestNum);
%     mixedInterestWeight=mixedInterestWeight(1:finalTopInterestNum,:);
    
    % ��������Ȩ�صĺ�
    totalWeight=sum(mixedInterestWeight(:,2));
    totalInterestRecList=[];
    
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
        
        % *****������Ȥ�����Ƽ�******     
        interestRecList=GetRecListByInterestCircle(testUserID,userInterestCircle,itemInterestCircle,userRatingMatrix,recThreshold,userAvgRating);
        
        % ��2�׷����������⣬��ʱ��ʹ��
        %interestRecList=GetRecListByInterestCircle2(testUserID,userInterestCircle,itemInterestCircle,userRatingMatrix,recThreshold,userAvgRating);
        
        % ����Ҫ�������Ȧ�ӵ����Ȩ��
        interestRecList(:,2)=interestRecList(:,2)*tempWeight;
        
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
    
    % ��¼һ��ÿ���û����Ƽ��б�ĳ��ȣ��������topK
    if size(totalInterestRecList,1)>0
        recListLengthRecord=[recListLengthRecord size(totalInterestRecList,1)];
    end
    
    % ȡǰK����ֻ��ID
    %     finalRecList=totalInterestRecList(1:topK,[1,3]);
    
    % ��topK�����ã������Ͳ�����
    if length(totalInterestRecList(:,1))<topK
        realTopK=length(totalInterestRecList(:,1));
        finalRecList=totalInterestRecList(1:realTopK,1);
    else
        finalRecList=totalInterestRecList(1:topK,1);
    end
    
    if isempty(finalRecList)
        % ���Ƽ�����Ϊ�գ�������Ƽ�
        continue;
    end
    
    % ��¼ÿ���û������յ��Ƽ��б�
    allUserFinalRecList{i}=finalRecList;
 
    %% **********************************�����ڶ�����ȡ�ò��Լ���Ŀ���û�ϲ����item�б�***********************
    % �����ִ���likeThreshold��ʾϲ��

    tempIndex=find(testSet(:,1)==testUser & testSet(:,3)>=likeThreshold);
    tempItemSet=testSet(tempIndex,2);
    
    [commonItem,IA,IB]=intersect(uniqItemData,tempItemSet);
    testUserLikedItemList=IA;
       
%     for m=1:length(tempItemSet)
%         itemSetID=find(uniqItemData==tempItemSet(m));
%         testUserLikedItemList=[testUserLikedItemList itemSetID];
%     end
    
    if isempty(testUserLikedItemList)
        % ���Լ��û���û�����ִ���3��item���򲻿�������û����Ƽ��������Ƽ�
        continue;
    end
    
    %% **************************************�����������������Ƽ�Ч��****************************************
    % ���Ƽ��б�Ͳ��Լ����û�ϲ����itemȡ��������Ϊhit����
    hitList=intersect(finalRecList,testUserLikedItemList);
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
   
        
    userInterestSet=zeros(interestCount,7);
    userInterestSet(:,1)= ratingInterestWeight(:,2)>0;  %������Ȥ
    userInterestSet(:,2)= socialInterestWeight(:,2)>0;  %�罻��Ȥ
    combineInterest= userInterestSet(:,1)+userInterestSet(:,2);
    userInterestSet(:,3)=combineInterest==2 ;          % �������罻�غ���Ȥ
    extraInterest= userInterestSet(:,2)-userInterestSet(:,1);
    userInterestSet(:,4)= extraInterest==-1 ;  %���ֵĶ�����Ȥ
    userInterestSet(:,5)= extraInterest==1;    %�罻�Ķ�����Ȥ;
    
    %����hitList��������Ȥ
    interestHit=GetItemInterest(hitList,itemClassIndex,interestCount);
    userInterestSet(:,6)=interestHit;
    
    % ���� ���Լ���relevant ��Ŀ��������Ȥ
      
    userInterestSet(:,7)=testUserID;
    allUserInterestSet{i}=userInterestSet;
    
    allUserResult(i,:)=[testUserID,precision,recall];  
    
    % �ܵ����ģ�����+1�������Ϊ��ĸ
    totalCount=totalCount+1;
    
end

%% #####################����ָ��###########################
%������ϡ���û��������û���׼ȷ���ٻ���

% ���ڼ�¼ϡ���û��������û��Ľ��
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
% �����û�����Ȥ���б���
% 1���� 2�罻 3�غ� 4���ֶ��� 5�罻����  6 ÿ����Ȥ��������
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
% �����û�����Ȥ����������
% 1���� 2�罻 3�غ� 4���ֶ��� 5�罻����  6ÿ����Ȥ��������
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

%����ȫ���������Ա�֮����з���
% save(saveAllDataFileName);
% end
% end

toc;

