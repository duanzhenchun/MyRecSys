clear;
tic;

%% ������
% ����SVD����������Ԥ�⣬�ٻ�������Ԥ�����topN�Ƽ�
version=1;
facNum=50;
date='7.1';
width=5;height=8;

trainSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\trainSet%d.txt',version);
ratingSomFileName=sprintf('..\\..\\..\\data\\baidu\\somdata\\baidu_%dx%d_som%d.mat',width,height,version); 
testSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\testSet%d.txt',version);
modelFileName=sprintf('..\\..\\..\\data\\baidu\\svddata\\svdModel%d_%d.mat',version,facNum); %SVDģ���ļ���
resultFileName=sprintf('..\\..\\..\\result\\baidu\\svd\\baidu_svd_result%d_%s.txt',version,date);
itemSimiFileName=sprintf('..\\..\\..\\data\\baidu\\ibcfdata\\itemSimiMatrix%d.mat',version);
userLevelFileName='..\\..\\..\\data\\baidu\\commondata\\userLevel.txt';
saveRecListFileName=sprintf('..\\..\\..\\data\\baidu\\svddata\\recList\\reclist%d.mat',version);

%%********��ʼ��****************
load(ratingSomFileName,'weight','itemClassIndex');
trainSet= load(trainSetFileName);
testSet=load(testSetFileName);
load(itemSimiFileName,'itemSimiMatrix');
userLevel=load(userLevelFileName);
% load model 
load(modelFileName,'avgRating','bu','bi','pu','qi','iterStep','factorNum');



userData=testSet(:,1);
itemData=trainSet(:,2);
uniqUserData=unique(userData);
uniqItemData=unique(itemData);
userCount=length(uniqUserData);
itemCount=length(uniqItemData);
interestCount=size(weight,1);
levelNum=length(unique(userLevel(:,2)));

testUserData=testSet(:,1);
uniqTestUserData=unique(testUserData);
testUserCount=length(uniqTestUserData);

% bu bi ����������
bu=bu';
repbu=repmat(bu,1,itemCount);
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
       
    % �ܵ����ģ�����+1�������Ϊ��ĸ
    totalCount=totalCount+1;
    
end

%% #####################����ָ��###########################

%����������Level�û��� ׼ȷ�� �ٻ��� F1
avgUserEvaluationByLevel=EvaluationAnalysis(allUserEvaluation,levelNum);

% ��������Level�û��Ƽ����Ͳ��Լ�֮�����Ȥ�ĸ��ǹ�ϵ
[avgUserRecTestItrByLevel,avgExRecTestItrRate]=RecTestSetInterestAnalysis(allUserFinalRecList,testSet,uniqItemData,likeThreshold,itemClassIndex,interestCount,userLevel);
avgExRecItrHitNumRate=avgExRecTestItrRate(1);
avgExTestItrHitNumRate=avgExRecTestItrRate(2);

avgPrecision=totalPrecision/totalCount;
avgRecall=totalRecall/totalCount;
avgF1=2*avgPrecision*avgRecall/(avgPrecision+avgRecall);
allRecListSet=[];

totalILS=0;
acount=0;
for i=1:testUserCount
    recListCell=allUserFinalRecList{i};
    if isempty(recListCell)
        continue
    end
    recList=recListCell{2};
    allRecListSet=[allRecListSet recList']; 
    if length(recList)>1                             
        tempILS=GetIntraListSimi(recList,itemSimiMatrix);
        totalILS=totalILS+tempILS;   
        acount=acount+1;       
    end  
end
avgILS=totalILS/acount;

uniqueAllRecListSet=unique(allRecListSet);
coverage=length(uniqueAllRecListSet)/itemCount;

resultStr=sprintf('the avgPrecision is %f, the avgRecall is %f, avgF1 is %f,coverage is %f,avgILS is %f',avgPrecision,avgRecall,avgF1,coverage,avgILS);
disp(resultStr);

%% *************���������*****************
fid = fopen(resultFileName,'a');
fprintf(fid,'--------------------------- parameter ---------------------------------\r\n');
fprintf(fid,'topK = %d,likeThreshold= %d ,factorNum= %d,iterStep=%d  \r\n',topK,likeThreshold,factorNum,iterStep);
fprintf(fid,'--------------------------- result ----------------------------------\r\n');
fprintf(fid,'the avgPrecision is %1.7f, the avgRecall is %1.7f, the avgF1 is %1.7f  ,the coverage is %f, the avgILS is %f  \r\n',avgPrecision,avgRecall,avgF1,coverage,avgILS);
fprintf(fid,'--------------------------  other record ------------------------------\r\n');
fprintf(fid,'the totalCount is %d \r\n\r\n',totalCount);
fprintf(fid,'--------------------- cutoff line ----------------------- \r\n');
fclose(fid);

%�����Ƽ��б��Ա�֮����з���
save(saveRecListFileName,'allUserFinalRecList');

toc;
        
        
        











