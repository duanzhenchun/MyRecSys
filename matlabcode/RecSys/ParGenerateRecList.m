clear;
clc;
% ���л��汾
% �������� ������userNumMap itemNumMap �Ծɵ�������ӳ�䣬
% ӳ�䵽�µ�����
load ratingSomOutcome1.mat ...
    uniqUserData uniqItemData ...
    userRatingMatrix weight itemClassIndex

userCount=length(uniqUserData);
itemCount=length(uniqItemData);

testSet= load('..\..\..\data\baidu\data1\testSet1.txt');
testUserData=testSet(:,1);
uniqTestUserData=unique(testUserData);
testUserCount=length(uniqTestUserData);
recListLengthRecord=[];

% *************һЩ��������*********************

topK=50;           % �����Ƽ��б�ǰtopK��
likeThreshold=3;   % �ж��û��Ƿ�ϲ��һ��item����ֵ��Ҫ������
circleScreenRate=0.4;  % ÿ����ȤȦ�� ���ѡ�ٷ�֮����neighbor����item�Ƽ�
interestScreenRate=0.4;

% �������û���Ȩ�ذ���������
allSortedWeightCell=GetAllSortedWeight(weight);
userInterestCircleCell=SplitUserByInterestCircle(allSortedWeightCell);
% ������item���ֵ���ͬ����
itemInterestCircleCell=SplitItemByInterestCircle(itemClassIndex,size(weight,1));

totalPrecision=0;
totalRecall=0;
totalF1=0;
%��Ϊ������ķ�ĸ
count=0;
for i=1:testUserCount
    if mod(i,150)==0
        disp ('20%');
    end

    % ���Ƽ��û�ID
    testUser=uniqTestUserData(i);
    % ��ѵ�����е�uniqUserData�� testuser��Ӧ��ID
    testUserID=find(uniqUserData==testUser);   

    % *************ȡ���û����Ƽ��б�*********************
    %ȡ��Ŀ���û���ȤȨֵ,�����û�������>0����Ȥ
    interestWeight=allSortedWeightCell{testUserID};
    tx0=find(interestWeight(:,2)>0);
    interestWeight=interestWeight(tx0,:);
    
    % ֻȡǰ�ٷ�֮ interestScreenRate ����Ȥ
    interestNum=size(interestWeight,1);
    finalInterestNum=min(ceil(interestNum*interestScreenRate),interestNum);
    interestWeight=interestWeight(1:finalInterestNum,:);
    
    % ��������Ȩ�صĺ�
    totalWeight=sum(interestWeight(:,2));
%         topInterestData=interestWeight(1:topInterestNum,:);
    totalInterestRecList=[];
    parfor j=1:size(interestWeight,1)
        %�����Ȩ��,����ںϲ�����Ȥ���ϣ�Ҫ����ȥ
        tempWeight=interestWeight(j,2)/totalWeight;
        % ��ȡ�ڸ���ȤȦ�������
        userInterestCircle=userInterestCircleCell{interestWeight(j,1)};
        % ����ȤС����ȥ���Լ�
        tx1=find(userInterestCircle(:,1)==testUserID);
        userInterestCircle(tx1,:)=[];         

        itemInterestCircle=itemInterestCircleCell{interestWeight(j,1)};
        interestRecList=GetRecListByInterestCircle(testUserID,userInterestCircle,itemInterestCircle,userRatingMatrix,circleScreenRate);
        % ����Ҫ�������Ȧ�ӵ����Ȩ��
        interestRecList(:,2)=interestRecList(:,2)*tempWeight;
        % ���ܸ�����ȤȦ�ӵĽ��
        totalInterestRecList=[totalInterestRecList;interestRecList]; 
    end
    % ����
    totalInterestRecList=-sortrows(-totalInterestRecList,2);

    % ȥ��testUser�Ѿ�������
    watchedItemList=find(userRatingMatrix(testUserID,:)>0);
    [c,ia]=intersect(totalInterestRecList(:,1),watchedItemList);
    totalInterestRecList(ia,:)=[];
    % ��¼һ��ÿ���û����Ƽ��б�ĳ��ȣ��������topK
    recListLengthRecord=[recListLengthRecord size(totalInterestRecList,1)];
    % ȡǰK����ֻ��ID
    finalRecList=totalInterestRecList(1:topK,1);

    % ***************ȡ���û����Լ����û�ϲ����item�б�*************   
    % �����ִ���likeThreshold��ʾϲ��
    testUserLikedItemList=[];
    tempIndex=find(testSet(:,1)==testUser & testSet(:,3)>likeThreshold);
    tempItemSet=testSet(tempIndex,2);
    for m=1:length(tempItemSet)
        itemSetID=find(uniqItemData==tempItemSet(m));
        testUserLikedItemList=[testUserLikedItemList itemSetID];
    end

    if isempty(testUserLikedItemList)
        % ���Լ��û���û�����ִ���3��item���򲻿�������û����Ƽ�������
        continue;
    end

    % ****************�����Ƽ�Ч��********************************
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
    if precision==0 || recall==0
        f1=0;
    else 
        f1=2*precision*recall/(precision+recall);
    end
    totalPrecision=totalPrecision+precision;
    totalRecall=totalRecall+recall;    
    totalF1=totalF1+f1;
    % �ܵ����ģ�����+1�������Ϊ��ĸ
    count=count+1;
end

avgPrecision=totalPrecision/count;
avgRecall=totalRecall/count;
avgF1=totalF1/count;
resultStr=sprintf('the avgPrecision is %f, the avgRecall is %f, avgF1 is %f',avgPrecision,avgRecall,avgF1);
disp(resultStr);

%     resultMatrix(mark,4)=avgPrecision;
%     resultMatrix(mark,5)=avgRecall;
%     resultMatrix(mark,6)=avgF1;
% end












