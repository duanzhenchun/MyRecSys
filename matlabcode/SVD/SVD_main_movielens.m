clear;
tic;

%% ������
% ����SVD����������Ԥ�⣬�ٻ�������Ԥ�����topN�Ƽ�
version=1;

date='7.1';


trainSetFileName=sprintf('..\\..\\..\\data\\movielens\\commondata\\trainSet%d.txt',version);

testSetFileName=sprintf('..\\..\\..\\data\\movielens\\commondata\\testSet%d.txt',version);
modelFileName=sprintf('..\\..\\..\\data\\movielens\\svddata\\svdModel1%d.mat',version); %SVDģ���ļ���
resultFileName=sprintf('..\\..\\..\\result\\movielens\\svd\\movielens_svd_result%d_%s.txt',version,date);


%%********��ʼ��****************

trainSet= load(trainSetFileName);
testSet=load(testSetFileName);

% load model 
load(modelFileName,'avgRating','bu','bi','pu','qi','iterStep','factorNum');



userData=testSet(:,1);
itemData=trainSet(:,2);
uniqUserData=unique(userData);
uniqItemData=unique(itemData);
userCount=length(uniqUserData);
itemCount=length(uniqItemData);



testUserData=testSet(:,1);
uniqTestUserData=unique(testUserData);
testUserCount=length(uniqTestUserData);

% bu bi ����������

repbu=repmat(bu,1,itemCount);
bi = bi';
repbi=repmat(bi,userCount,1);
predictRatingMatrix=avgRating+repbu+repbi+pu*qi';

topK=50; 
likeThreshold=4; 
totalPrecision=0; totalRecall=0; 
totalCount=0;
 % ��¼��ÿ���û����Ƽ��б�
allUserFinalRecList=cell(testUserCount,1);  
% ��¼�����û��Ľ��
allUserEvaluation=ones(length(testUserCount),4)*(-1);


%% ����
fprintf('start the iteration ...')
parfor i=1:testUserCount
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
    
    % ȡǰtopK����Ϊ����Ƽ�;
    finalRecList=itemRatingList(1:topK,1);
    
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






%% *************���������*****************


toc;
        
        
        











