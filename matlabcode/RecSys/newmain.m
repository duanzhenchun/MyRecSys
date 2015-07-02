clear;
clc;
tic;

%% ������
% �����û���Ȥ���Ƽ�
% �ֱ���������Ϣ���罻��Ϣ���ھ��û�����Ȥ
% �ҳ��û�����Ȥ���ٻ�����Ȥ���������Ƽ�

%% **************���ļ�����ʹ洢��Ŀ¼���������趨*********************************

ratingSomFileName='..\..\..\data\baidu\ratingSomOutcome3.mat';
communityFileName='..\..\..\data\baidu\community1.mat';
socialFileName='..\..\..\data\baidu\data1\finalSocial.txt';
testSetFileName='..\..\..\data\baidu\data1\testSet1.txt';
resultFileName='..\..\..\data\baidu\result\baidu_result1.txt';

%% ********************����֮ǰ�����õ�����**********************************

% addpath '..\..\..\code\matlabcode\FastNewman'
% ����SOM���־����Ľ��
load(ratingSomFileName, 'uniqUserData', 'uniqItemData', ...
    'userRatingMatrix','weight', 'itemClassIndex');
% �����������ֺ�Ľ��
load(communityFileName,'communityCell');
testSet= load(testSetFileName);
socialData=load(socialFileName);
format long;

%% ******************���г�ʼ��***************************

userCount=length(uniqUserData);
itemCount=length(uniqItemData);
testUserData=testSet(:,1);
uniqTestUserData=unique(testUserData);
testUserCount=length(uniqTestUserData);

% �����ڽӾ���
socialMatrix=zeros(userCount,userCount);
for m=1:size(socialData,1)
    socialLink=socialData(m,:);
    sourceUser=socialLink(1);
    targetUser=socialLink(2);
    sourceUserID=find(uniqUserData==sourceUser);
    targetUserID=find(uniqUserData==targetUser);
    %�ԳƵ��罻��ϵ
    socialMatrix(sourceUserID,targetUserID)=1;
    socialMatrix(targetUserID,sourceUserID)=1;
end

% ��ȡ�û���������ӳ�����1�д��û�ID����2�д�ÿ���û��������������
userCommunityMap=GetUserCommunityMap(communityCell);

% ��ȡtrust��Ϣ
% trustMatrixCommuMapCell��ÿ��������trust����
% trustNodeMapCell ��ÿ���������û�ID��ӳ�䣬��ÿ�������ڲ���Ҫ���û����´�1��ʼ��ţ����㴦��
% ��1��Ϊӳ���������ڵ�ID����1��ʼ����2��Ϊ������ȫ�ֵ��û�ID���
[trustMatrixCommuMapCell,trustNodeMapCell]=GetTrustMatrixByCommunity(communityCell,socialMatrix);

% ��������û�����ȤȨ�أ�������������
allSortedWeightCell=GetAllSortedWeight(weight);
% �������û����ֵ���ͬ��Ȥ����ȥ����ͬ��֮���û������ص�
userInterestCircleCell=SplitUserByInterestCircle(allSortedWeightCell);
% ������item���ֵ���ͬ��Ȥ���У���֮��item���ص�
itemInterestCircleCell=SplitItemByInterestCircle(itemClassIndex,size(weight,1));

% ��������û����۴��
 userAvgRating=GetAllUserAvgRating(userRatingMatrix);

%% **** ��������� *******
% topKList=(10:10:100);
% topMList=(0.5:0.1:1);
% topPeopleRateList=(0.3:0.1:1);
% for iter=1:length(topMList)

%% ***************�������ü�һЩ��ʼ������*********************
topK=50;           % �����Ƽ��б�ǰtopK��
likeThreshold=3;   % �ж��û��Ƿ�ϲ��һ��item����ֵ��Ҫ������
circlePeopleCutRate=0.4;  % ÿ����ȤȦ�� ���ѡ�ٷ�֮����neighbor����item�Ƽ�
topMInterestRate=0.5;   % ȡǰ�ٷ�֮���ٵ���Ȥ
alpha=0.5; % ��Ȥ�ϲ��Ĳ�����rating=alpha��social=1-alpha
recThreshold=3;  % ����������Ȥ�����Ƽ�ʱ����ÿ����ȤȦ�Ԥ������Ҫ���������ֵ�Żᱻ�Ƽ�
recListLengthRecord=[];  %��¼һ��ÿ���û����Ƽ��б�ĳ��ȣ��������topK
totalPrecision=0; totalRecall=0; 
%��Ϊ������precision,recall ,f1�ķ�ĸ
totalCount=0;

%% *******************��ʼ����************************
for i=1:testUserCount
% for i=55
    
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
    
    ratingInterestWeight=zeros(size(weight,1),2);
    ratingInterestWeight(:,1)=(1:size(weight,1));
    ratingInterestWeight(:,2)=weight(:,testUserID);
    % ��һ��
    totalWeight1=sum(ratingInterestWeight(:,2));
    ratingInterestWeight(:,2)=ratingInterestWeight(:,2)/totalWeight1;
    
    %% ***********ȡ��Ŀ���û������罻��Ϣ�õ�����Ȥ��Ȩ��*************
    
    userSocialCircle=FindUserSocialCircle(testUserID,userCommunityMap,trustMatrixCommuMapCell,trustNodeMapCell);
    socialInterestWeight=GetSocialInterestWeight(userSocialCircle,weight);
    % ��һ��
    totalWeight2=sum(socialInterestWeight(:,2));
    socialInterestWeight(:,2)=socialInterestWeight(:,2)/totalWeight2;
    
    %% ***************��Ȥ�ϲ�*************************
    mixedInterestWeight=zeros(size(weight,1),2);
    mixedInterestWeight(:,1)=(1:size(weight,1));
    mixedInterestWeight(:,2)=alpha*ratingInterestWeight(:,2)+(1-alpha)*socialInterestWeight(:,2);
    % ȥ��Ϊ0����Ȥ
    tx0=find(mixedInterestWeight(:,2)>0);
    mixedInterestWeight=mixedInterestWeight(tx0,:);
    % ��������
    mixedInterestWeight=-sortrows(-mixedInterestWeight,2);
    
    %% ***********ȡ���û�ǰ�ٷ�֮M����Ȥ��Ȩ��*******************
    
    %ȡǰ�ٷ�֮M����Ȥ����Ȩ��
    totalInterestNum=size(mixedInterestWeight(:,1),1);
    topInterestNum=ceil(topMInterestRate*totalInterestNum);
    finalTopInterestNum=min(topInterestNum,totalInterestNum);
    mixedInterestWeight=mixedInterestWeight(1:finalTopInterestNum,:);
    % ��������Ȩ�صĺ�
    totalWeight=sum(mixedInterestWeight(:,2));
    totalInterestRecList=[];
    %% *************����Ŀ���û�ÿһ����Ȥ����һ���Ƽ��б���ȥ���û��Ѿ�������*********************
    for j=1:size(mixedInterestWeight,1)
        
        % �����Ȩ��,����ٺϲ�����Ȥ���ϣ�Ҫ����ȥ
        tempWeight=mixedInterestWeight(j,2)/totalWeight;
        % ��ȡ�ڸ���ȤȦ�������
        userInterestCircle=userInterestCircleCell{mixedInterestWeight(j,1)};
        % ����ȤС����ȥ���Լ�
        idx1=find(userInterestCircle(:,1)==testUserID);
        userInterestCircle(idx1,:)=[];
        % ��ȡ���ֵ�����ȤȦ��item
        itemInterestCircle=itemInterestCircleCell{mixedInterestWeight(j,1)};
        
        % *****������Ȥ�����Ƽ�******
        interestRecList=GetRecListByInterestCircle(testUserID,userInterestCircle,itemInterestCircle,userRatingMatrix,circlePeopleCutRate,recThreshold);
        
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
    
    % �Ժϲ�����Ƽ��б���ָߵͽ������򣬽�������
    totalInterestRecList=-sortrows(-totalInterestRecList,2);
    
    % ȥ��testUser�Ѿ�������
    watchedItemList=find(userRatingMatrix(testUserID,:)>0);
    [c,ia]=intersect(totalInterestRecList(:,1),watchedItemList);
    totalInterestRecList(ia,:)=[];
    
    % ��¼һ��ÿ���û����Ƽ��б�ĳ��ȣ��������topK
    recListLengthRecord=[recListLengthRecord size(totalInterestRecList,1)];
    % ȡǰK����ֻ��ID
    %     finalRecList=totalInterestRecList(1:topK,[1,3]);
    finalRecList=totalInterestRecList(1:topK,1);
    
    if isempty(finalRecList)
        % ���Ƽ�����Ϊ�գ�������Ƽ�
        continue;
    end
    
    
    %% **********************************�����ڶ�����ȡ�ò��Լ���Ŀ���û�ϲ����item�б�***********************
    % �����ִ���likeThreshold��ʾϲ��
    testUserLikedItemList=[];
    tempIndex=find(testSet(:,1)==testUser & testSet(:,3)>likeThreshold);
    tempItemSet=testSet(tempIndex,2);
    for m=1:length(tempItemSet)
        itemSetID=find(uniqItemData==tempItemSet(m));
        testUserLikedItemList=[testUserLikedItemList itemSetID];
    end
    
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
    % �ܵ����ģ�����+1�������Ϊ��ĸ
    totalCount=totalCount+1;
end

%% *******************�õ����Ľ��****************************
avgPrecision=totalPrecision/totalCount;
avgRecall=totalRecall/totalCount;
avgF1=2*avgPrecision*avgRecall/(avgPrecision+avgRecall);
resultStr=sprintf('the avgPrecision is %f, the avgRecall is %f, avgF1 is %f',avgPrecision,avgRecall,avgF1);
disp(resultStr);
% ����topK���컨�壬�����ĸ�ֵ���Ͳ�����ȡ��
topKCeil= min(recListLengthRecord);

%% *************���������*****************

fid = fopen(resultFileName,'a');
fprintf(fid,'topK = %d, circlePeopleCutRate = %1.2f,topMInterestRate = %1.2f ,likeThreshold= %i ,recThreshold= %1.2f  \r\n',topK,circlePeopleCutRate,topMInterestRate,likeThreshold,recThreshold);
fprintf(fid,'the avgPrecision is %1.7f, the avgRecall is %1.7f, the avgF1 is %1.7f \r\n',avgPrecision,avgRecall,avgF1);
fprintf(fid,'the topK ceil is %i \r\n\r\n',topKCeil);
fprintf(fid,'--------------------- cutoff line ----------------------- \r\n');
fclose(fid);


toc;

