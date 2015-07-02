clear;
tic;

%% ������
% ����SVD����������Ԥ�⣬�ٻ�������Ԥ�����topN�Ƽ�
date='8.26';
version = 1;

trainSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\trainSet%d.txt',version);
testSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\testSet%d.txt',version);
userRatingMatrixFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\userRatingMatrix%d.mat',version);
modelFileName = sprintf('..\\..\\..\\data\\baidu\\mfdata_topN\\2MF_iter300_fac10_rm1_wm0.020_lamb0.100.mat'); %SVDģ���ļ���
finalUserFileName = '..\\..\\..\\data\\baidu\\commondata\\finalUserID.txt';
%%********��ʼ��****************

trainSet= load(trainSetFileName);
testSet=load(testSetFileName);
finalUser = load(finalUserFileName);
% load model 
load(modelFileName,'Q','P','rm');
load(userRatingMatrixFileName,'userRatingMatrix');

userData=finalUser;
itemData=trainSet(:,2);
uniqUserData=unique(userData);
uniqItemData=unique(itemData);
userCount=length(uniqUserData);
itemCount=length(uniqItemData);

testUserData=testSet(:,1);
uniqTestUserData=unique(testUserData);
testUserCount=length(uniqTestUserData);


predictRatingMatrix=rm+Q*P';
% topKList = (10:10:90);
% for iter=1:length(topKList)
topK=100;
fprintf('current topK is %d \n',topK);
likeThreshold=4; 
totalPrecision=0; totalRecall=0; 
totalCount=0;
 % ��¼��ÿ���û����Ƽ��б�
allUserFinalRecList=cell(testUserCount,1);  


%% ����
fprintf('start the iteration ... \n')
for i=1:testUserCount
%     disp(i);
    the20num=round(0.2*testUserCount);
    if mod(i,the20num)==0
        disp ('20%');
    end
    
    % ���Ƽ��û�ID
    testUser=uniqTestUserData(i);
    % ��ѵ�����е�uniqUserData�� testuser��Ӧ��ID
    testUserID=find(uniqUserData==testUser);
    
   %% *********�������־���ȡ���û����Ƽ��б�****************
    predictRatingVector=predictRatingMatrix(testUserID,:);
    itemRatingList=zeros(itemCount,2);
    itemRatingList(:,1)=(1:itemCount);
    itemRatingList(:,2)=predictRatingVector;
    
    % ���������ý�������
    itemRatingList=-sortrows(-itemRatingList,2);
    
    % ȥ��testUser�Ѿ�������
    watchedItemList=find(userRatingMatrix(testUserID,:)>0);
    [c,ia]=intersect(itemRatingList(:,1),watchedItemList);
    itemRatingList(ia,:)=[];
    
    
    % ��topK�����ã������Ͳ�����
    if length(itemRatingList(:,1))<topK
        realTopK=length(itemRatingList(:,1));
        finalRecList=itemRatingList(1:realTopK,1);
    else
        finalRecList=itemRatingList(1:topK,1);
    end
    
    
    if isempty(finalRecList)
        % ���Ƽ�����Ϊ�գ�������Ƽ�
        continue;
    end
    

    
    %% ********ȡ�ò��Լ���Ŀ���û�ϲ����item�б�*******
    % �����ִ���likeThreshold��ʾϲ��
    
    tempIndex=find(testSet(:,1)==testUser & testSet(:,3)>=likeThreshold);
    tempItemSet=testSet(tempIndex,2);
    
    [commonItem,IA,IB]=intersect(uniqItemData,tempItemSet);
    testUserLikedItemList=IA;
    
    if isempty(testUserLikedItemList)
        % ���Լ��û���û�����ִ���3��item���򲻿�������û����Ƽ��������Ƽ�
        continue;
    end
    
    
    %% ***********�����Ƽ�Ч��************************
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
   
    
    % ��¼ÿ���û������յ��Ƽ��б�
    recListCell=cell(1,2);
    recListCell{1}=testUser;
    recListCell{2}=finalRecList;
    allUserFinalRecList{i}=recListCell;
       
    % �ܵ����ģ�����+1�������Ϊ��ĸ
    totalCount=totalCount+1;
    
end

%% #####################����ָ��###########################


avgPrecision=totalPrecision/totalCount;
avgRecall=totalRecall/totalCount;
avgF1=2*avgPrecision*avgRecall/(avgPrecision+avgRecall);

resultStr=sprintf('the avgPrecision is %f, the avgRecall is %f, avgF1 is %f',avgPrecision,avgRecall,avgF1);
disp(resultStr);


% end

toc;
        
        
        











