clear;
clc;
%% ������
%% ������ ���������������Ƽ��б� �Լ� ���罻�����������Ƽ�

%% ********************�����������,��һЩ��������**********************************
load ratingSomOutcome1.mat ...
    uniqUserData uniqItemData ...
    userRatingMatrix weight itemClassIndex

userCount=length(uniqUserData);
itemCount=length(uniqItemData);

testSet= load('..\..\..\data\baidu\data1\testSet1.txt');
testUserData=testSet(:,1);
uniqTestUserData=unique(testUserData);
testUserCount=length(uniqTestUserData);



% �������û���Ȩ�ذ���������
allSortedWeightCell=GetAllSortedWeight(weight);
userInterestCircleCell=SplitUserByInterestCircle(allSortedWeightCell);
% ������item���ֵ���ͬ����
itemInterestCircleCell=SplitItemByInterestCircle(itemClassIndex,size(weight,1));   


%% ***************�������ü�һЩ��ʼ������*********************
topK=50;           % �����Ƽ��б�ǰtopK��
likeThreshold=3;   % �ж��û��Ƿ�ϲ��һ��item����ֵ��Ҫ������
circlePeopleCutRate=0.4;  % ÿ����ȤȦ�� ���ѡ�ٷ�֮����neighbor����item�Ƽ�
topMInterestRate=0.5;   % ȡǰ�ٷ�֮���ٵ���Ȥ

recListLengthRecord=[];  %��¼һ��ÿ���û����Ƽ��б�ĳ��ȣ��������topK
totalPrecision=0; totalRecall=0; 
%��Ϊ������precision,recall ,f1�ķ�ĸ
count=0;


%% *******************��ʼ����************************
for i=1:testUserCount

    the20num=round(0.2*testUserCount);
    if mod(i,the20num)==0
        disp ('20%');
    end
   %% ***********��ÿ��Ŀ���û�����һЩ��ʼ��****************
    % ���Ƽ��û�ID
    testUser=uniqTestUserData(i);
    % ��ѵ�����е�uniqUserData�� testuser��Ӧ��ID
    testUserID=find(uniqUserData==testUser);   
    
    totalInterestRecList=[];  % ������Ȥ���Ƽ����б�
    totalSocialRecList=[];    % �����罻���Ƽ����б�
    finalRecList=[];          % �ϲ�������Ƽ��б�
    
%% *********************************������һ����ȡ��Ŀ���û����Ƽ��б�*********************

   %% ***********ȡ���û�ǰ�ٷ�֮M����Ȥ��Ȩ��*******************
    %ȡ��Ŀ���û���ȤȨֵ
    interestWeight=allSortedWeightCell{testUserID};
    %�����û�������>0����Ȥ
    tx0=find(interestWeight(:,2)>0);
    interestWeight=interestWeight(tx0,:); 
    %ȡǰ�ٷ�֮M����Ȥ����Ȩ��
    totalInterestNum=size(interestWeight(:,1),1);
    topInterestNum=ceil(topMInterestRate*totalInterestNum);
    finalTopInterestNum=min(topInterestNum,totalInterestNum);
    interestWeight=interestWeight(1:finalTopInterestNum,:);
    % ��������Ȩ�صĺ�
    totalWeight=sum(interestWeight(:,2));
    
    %% *************����Ŀ���û�ÿһ����ȤȦ����һ���Ƽ��б���ȥ���û��Ѿ�������*********************
    for j=1:size(interestWeight,1)
        % �����Ȩ��,����ںϲ�����Ȥ���ϣ�Ҫ����ȥ
        tempWeight=interestWeight(j,2)/totalWeight;
        % ��ȡ�ڸ���ȤȦ�������
        userInterestCircle=userInterestCircleCell{interestWeight(j,1)};
        % ����ȤС����ȥ���Լ�
        tx1=find(userInterestCircle(:,1)==testUserID);
        userInterestCircle(tx1,:)=[];         

        itemInterestCircle=itemInterestCircleCell{interestWeight(j,1)};
        interestRecList=GetRecListByInterestCircle(testUserID,userInterestCircle,itemInterestCircle,userRatingMatrix,circlePeopleCutRate);
        % ����Ҫ�������Ȧ�ӵ����Ȩ��
        interestRecList(:,2)=interestRecList(:,2)*tempWeight;
        % �����һ����ע������item��������Ȥ���ID����ʱ���ٸĻ���
        completeInterestRecList=zeros(size(interestRecList,1),3);
        completeInterestRecList(:,1:2)=interestRecList;
        completeInterestRecList(:,3)=interestWeight(j,1);
        % ���ܸ�����ȤȦ�ӵĽ��
%         totalInterestRecList=[totalInterestRecList;interestRecList]; 
        totalInterestRecList=[totalInterestRecList;completeInterestRecList]; 
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
  
   %% ****************����Ŀ���û��罻Ȧ����һ���Ƽ��б���ȥ���û��Ѿ�������*********************
    % �����
    
   %% ***********************�ϲ�����Ȧ�Ӳ������Ƽ��б�***************************************
    % �����
   
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
    count=count+1;
end

%% *******************�õ����Ľ��****************************
avgPrecision=totalPrecision/count;
avgRecall=totalRecall/count;
avgF1=2*avgPrecision*avgRecall/(avgPrecision+avgRecall);
resultStr=sprintf('the avgPrecision is %f, the avgRecall is %f, avgF1 is %f',avgPrecision,avgRecall,avgF1);
disp(resultStr);
% ����topK���컨�壬�����ĸ�ֵ���Ͳ�����ȡ��
topKCeil= min(recListLengthRecord);

%% *************���������*****************

fid = fopen('baiduresult.txt','a');
fprintf(fid,'topK = %d, circlePeopleCutRate = %1.2f,topMInterestRate = %1.2f ,likeThreshold= %i \r\n',topK,circlePeopleCutRate,topMInterestRate,likeThreshold);
fprintf(fid,'the avgPrecision is %1.7f, the avgRecall is %1.7f, the avgF1 is %1.7f \r\n',avgPrecision,avgRecall,avgF1);
fprintf(fid,'the topK ceil is %i \r\n\r\n',topKCeil);
fprintf(fid,'--------------------- cutoff line ----------------------- \r\n');
fclose(fid);
 




