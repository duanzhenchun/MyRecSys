clear;
tic;

%% ������
% ����SVD����������Ԥ�⣬�ٻ�������Ԥ�����topN�Ƽ�
date='8.26';

for version=1:1
fprintf('---------------the current version is %d ----------------- \n',version);

trainSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\trainSet%d.txt',version);
testSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\testSet%d.txt',version);
userRatingMatrixFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\userRatingMatrix%d.mat',version);
userLevelFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\userLevel.txt');
coreUserFileName = sprintf('..\\..\\..\\data\\baidu\\commondata\\coreUserID.txt');

modelFileName = sprintf('..\\..\\..\\data\\baidu\\mfdata_topN\\notW_MF_fac50_rm1_wm0.000_lamb0.100_ver%d.mat',version); %SVDģ���ļ���

%%********��ʼ��****************

% load model 
load(modelFileName,'Q','P','rm');
trainSet = load(trainSetFileName);
testSet= load(testSetFileName);
load(userRatingMatrixFileName,'userRatingMatrix');

userLevel = load(userLevelFileName);
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


predictRatingMatrix=rm+Q*P';

%% *************һЩ��������********************
likeThreshold=4;
topKList=(10:10:100);

recListLengthRecord=[]; % ��¼һ��ÿ���û����Ƽ��б�ĳ��ȣ��������topK

 % ��¼��ÿ���û����Ƽ��б�
allUserFinalRecList=cell(testUserCount,1);  
% ��¼�����û��Ľ��
allUserEvaluation=zeros(testUserCount,4);

totalPrecision = zeros(1,10);
totalRecall = zeros(1,10);
totalCount=0; %��Ϊ������precision,recall ,f1�ķ�ĸ
notCount = 0; % ���Լ�����û�����ִ��ڵ���4��

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
    
    levelIdx=find(userLevel(:,1)==testUser);
    level=userLevel(levelIdx,2);
    
    
   %% *********�������־���ȡ���û����Ƽ��б�****************
    predictRatingVector=predictRatingMatrix(testUserID,:);
    itemRankList=zeros(itemCount,2);
    itemRankList(:,1)=(1:itemCount);
    itemRankList(:,2)=predictRatingVector;
    
    % ���������ý�������
    itemRankList=-sortrows(-itemRankList,2);
    
    % ȥ��testUser�Ѿ�������
    watchedItemList=find(userRatingMatrix(testUserID,:)>0);
    [c,ia]=intersect(itemRankList(:,1),watchedItemList);
    itemRankList(ia,:)=[];
    
    finalRecList = cell(10,1);
    for m = 1:10
        % ��topK�����ã������Ͳ�����
        if length(itemRankList(:,1))< topKList(m)
            realTopK=length(itemRankList(:,1));
            finalRecList{m}=itemRankList(1:realTopK,1);
        else
            finalRecList{m}=itemRankList(1:topKList(m),1);
        end
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
    precisionList= [];
    recallList = [];
    for m = 1:10
        % ���Ƽ��б�Ͳ��Լ����û�ϲ����itemȡ��������Ϊhit����
        if isempty(finalRecList{m})
            hitList = [];
            % ���㵥���û���precision��recall
            precision = 0;
            recall = 0 ;
        else
            [hitList,iia,iib] = intersect(finalRecList{m},testUserLikedItemList);
            % ���㵥���û���precision��recall
            precision=length(hitList)/topKList(m);
            recall=length(hitList)/length(testUserLikedItemList);
        end

        if isnan(recall) || isnan(precision)
            disp('there is something wrong with the recall or the precision');
        end
        precisionList = [precisionList precision];
        recallList = [recallList recall];
     
        if m==10
            allUserEvaluation(i,:)=[testUser,precision,recall,level];
        end
    end
    totalPrecision = totalPrecision + precisionList;
    totalRecall = totalRecall + recallList;
    
    % ��¼ÿ���û������յ��Ƽ��б�
    recListCell=cell(1,2);
    recListCell{1}=testUser;
    recListCell{2}=finalRecList{10};
    allUserFinalRecList{i}=recListCell;
       
    % �ܵ����ģ�����+1�������Ϊ��ĸ
    totalCount=totalCount+1;
    
end

%% #####################����ָ��###########################


avgPrecision=totalPrecision/totalCount;
avgRecall=totalRecall/totalCount;
avgF1=2*avgPrecision.*avgRecall./(avgPrecision+avgRecall);

%����������Level�û��� ׼ȷ�� �ٻ��� F1
% avgUserEvaluationByLevel = EvaluationAnalysis(allUserEvaluation, levelNum);
avgTwoEvaluation=OnlyTwoEvaluation(allUserEvaluation);

fprintf('the precision is \n')
disp(avgPrecision);
fprintf('the recall is \n')
disp(avgRecall);
fprintf('the f1 is \n')
disp(avgF1);

itemSimiFileName = sprintf('..\\..\\..\\data\\baidu\\ibcfdata\\itemSimiMatrix%d.mat',version);
load(itemSimiFileName,'itemSimiMatrix');
itemDistMatrix = 1 - itemSimiMatrix;
clear itemSimiMatrix;
itemPopularity = GetItemPopularity(userRatingMatrix);
[coverage,avgILD,novelty] = DiversityAnalysis(allUserFinalRecList,itemDistMatrix,itemPopularity,itemCount,userCount);
avgILD = avgILD/2;
fprintf('coverage is %f, avgILD is %f,novelty is %f \n ',coverage,avgILD,novelty);
clear itemDistMatrix;

% ����topK���컨�壬�����ĸ�ֵ���Ͳ�����ȡ��
topKCeil= min(recListLengthRecord);

%% *************���������*****************

% **********final ʵ���� ***************

for m =1 :10
    topK = topKList(m);
    finalResultFileName=sprintf('..\\..\\..\\huiyiresult\\baidu\\SVD\\final_baidu_SVD_prf_top%d.txt',topK);

    fid = fopen(finalResultFileName,'a');
    fprintf(fid,'%f\t%f\t%f\r\n',avgPrecision(m),avgRecall(m),avgF1(m));
    fclose(fid);
end

finalDiversityFileName=sprintf('..\\..\\..\\huiyiresult\\baidu\\SVD\\final_baidu_SVD_diversity.txt');
finalColdUserResultFileName = sprintf('..\\..\\..\\huiyiresult\\baidu\\SVD\\final_baidu_SVD_colduser.txt');
finalHotUserResultFileName = sprintf('..\\..\\..\\huiyiresult\\baidu\\SVD\\final_baidu_SVD_hotuser.txt');


fid = fopen(finalDiversityFileName,'a');
fprintf(fid,'%f\t%f\t%f\r\n',coverage,avgILD,novelty);
fclose(fid);

fid = fopen(finalColdUserResultFileName,'a');
fprintf(fid,'%f\t%f\t%f\r\n',avgTwoEvaluation(1,2),avgTwoEvaluation(1,3),avgTwoEvaluation(1,4));
fclose(fid);

fid = fopen(finalHotUserResultFileName,'a');
fprintf(fid,'%f\t%f\t%f\r\n',avgTwoEvaluation(2,2),avgTwoEvaluation(2,3),avgTwoEvaluation(2,4));
fclose(fid);




toc;
        
        
        



end







