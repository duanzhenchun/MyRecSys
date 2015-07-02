clear;
tic;

%% ������
% ����SVD����������Ԥ�⣬�ٻ�������Ԥ�����topN�Ƽ�
date='10.21';
version = 1;
fprintf('---------------the current version is %d ----------------- \n',version);

trainSetFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\trainSet%d.txt',version);
testSetFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\testSet%d.txt',version);
userRatingMatrixFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\userRatingMatrix%d.mat',version);
resultFileName=sprintf('..\\..\\..\\result\\flixster\\mf_topN\\flixster_mf_result_%d_%s.txt',version,date);
coreUserFileName =sprintf( '..\\..\\..\\data\\flixster\\commondata\\coreUserID%d.txt',version);
userLevelFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\userLevel%d.txt',version);
modelFileName = sprintf('..\\..\\..\\data\\flixster\\mfdata_topN\\MF_fac20_rm-1_wm0.400_lamb0.100_ver%d.mat',version); %SVDģ���ļ���
itemSimiFileName=sprintf('..\\..\\..\\data\\flixster\\ibcfdata\\MF_itemSimiMatrix%d.mat',version);

%%********��ʼ��****************

trainSet= load(trainSetFileName);
testSet=load(testSetFileName);
% load model 
load(modelFileName,'Q','P','rm');
load(userRatingMatrixFileName,'userRatingMatrix');
userLevel=load(userLevelFileName);

coreUser = load(coreUserFileName);

userData=coreUser;
itemData=trainSet(:,2);
uniqUserData=unique(userData);
uniqItemData=unique(itemData);
userCount=length(uniqUserData);
itemCount=length(uniqItemData);
levelNum=length(unique(userLevel(:,2)));

testUserData=testSet(:,1);
uniqTestUserData=unique(testUserData);
testUserCount=length(uniqTestUserData);

% topKList=(10:10:100);
% for iter1=1:length(topKList)
% topK=topKList(iter1); 
topK =50;
fprintf('current topK is %d \n',topK);
likeThreshold=4; 
recListLengthRecord=[]; % ��¼һ��ÿ���û����Ƽ��б�ĳ��ȣ��������topK

 % ��¼��ÿ���û����Ƽ��б�
allUserFinalRecList=cell(testUserCount,1);  
% ��¼�����û��Ľ��
allUserEvaluation=zeros(testUserCount,4);

totalPrecision=0; totalRecall=0; 
totalCount=0; %��Ϊ������precision,recall ,f1�ķ�ĸ
notCount = 0; % ���Լ�����û�����ִ��ڵ���4��

%% ����
fprintf('start the iteration ... \n')
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
    
    levelIdx=find(userLevel(:,1)==testUser);
    level=userLevel(levelIdx,2);   
    
   %% *********�������־���ȡ���û����Ƽ��б�****************
    predictRatingVector= rm + Q(testUserID,:) * P';
    itemRatingList=zeros(itemCount,2);
    itemRatingList(:,1)=(1:itemCount);
    itemRatingList(:,2)=predictRatingVector;
    
    % ���������ý�������
    itemRatingList=-sortrows(-itemRatingList,2);
    
    % ȥ��testUser�Ѿ�������
    watchedItemList=find(userRatingMatrix(testUserID,:)>0);
    [c,ia]=intersect(itemRatingList(:,1),watchedItemList);
    itemRatingList(ia,:)=[];
    
    recListLengthRecord=[recListLengthRecord; [testUser size(itemRatingList,1)]];
  
    % ��topK�����ã������Ͳ�����
    if length(itemRatingList(:,1))<topK
        realTopK=length(itemRatingList(:,1));
        finalRecList=itemRatingList(1:realTopK,1);
    else
        finalRecList=itemRatingList(1:topK,1);
    end
     
    %% ********ȡ�ò��Լ���Ŀ���û�ϲ����item�б�*******
    % �����ִ���likeThreshold��ʾϲ��
    
    tempIndex=find(testSet(:,1)==testUser & testSet(:,3)>=likeThreshold);
    tempItemSet=testSet(tempIndex,2);
    
    [commonItem,IA,IB]=intersect(uniqItemData,tempItemSet);
    testUserLikedItemList=IA;
    
    if isempty(testUserLikedItemList)
        % ���Լ��û���û�����ִ���3��item���򲻿�������û����Ƽ��������Ƽ�
         notCount = notCount+1;
         continue;
    end
    
    
    %% ***********�����Ƽ�Ч��************************
     % ���Ƽ��б�Ͳ��Լ����û�ϲ����itemȡ��������Ϊhit����
    if isempty(finalRecList)
        hitList = [];
        % ���㵥���û���precision��recall
        precision = 0;
        recall = 0 ;
    else
        [hitList,iia,iib] = intersect(finalRecList,testUserLikedItemList);
        % ���㵥���û���precision��recall
        precision=length(hitList)/topK;
        recall=length(hitList)/length(testUserLikedItemList);
    end
          
    if isnan(recall) || isnan(precision)
        disp('there is something wrong with the recall or the precision');
    end
    totalPrecision=totalPrecision+precision;
    totalRecall=totalRecall+recall;  
   
    allUserEvaluation(i,:)=[testUser,precision,recall,level];
        
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

%����������Level�û��� ׼ȷ�� �ٻ��� F1
% avgUserEvaluationByLevel = EvaluationAnalysis(allUserEvaluation, levelNum);
avgTwoEvaluation=OnlyTwoEvaluation(allUserEvaluation);

% load(itemSimiFileName,'itemSimiMatrix');
% itemDistMatrix = 1 - itemSimiMatrix;
% itemPopularity = GetItemPopularity(userRatingMatrix);
% [coverage,avgILD,novelty]  =DiversityAnalysis(allUserFinalRecList,itemDistMatrix,itemPopularity,itemCount,userCount);
% fprintf('coverage is %f, avgILD is %f,novelty is %f \n ',coverage,avgILD,novelty);

resultStr=sprintf('the avgPrecision is %f, the avgRecall is %f, avgF1 is %f ',avgPrecision,avgRecall,avgF1);
disp(resultStr);
topKCeil= min(recListLengthRecord);

% fid = fopen(resultFileName,'a');
% fprintf(fid,'--------------------------- parameter ---------------------------------\r\n');
% fprintf(fid,'version is %d  ',version);
% fprintf(fid,'topK = %d, likeThreshold= %d  \r\n',topK,likeThreshold);
% fprintf(fid,'the avgPrecision is %1.7f, the avgRecall is %1.7f, the avgF1 is %1.7f  \r\n\r\n',avgPrecision,avgRecall,avgF1);
% fclose(fid);

%% ******��ʽʵ��ר��*************
% fid = fopen(resultFileName,'a');
% fprintf(fid,'%f\t%f\t%f\r\n',avgPrecision,avgRecall,avgF1);
% fclose(fid);


% end

toc;
        
        
        











