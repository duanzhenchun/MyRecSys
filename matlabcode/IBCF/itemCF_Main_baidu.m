%% item-based cf
clear;
tic;

%% ****************************** һЩ��ʼ������ ***********************************************
date='8.26';

versionSum=1;

for version=1:10
    
fprintf('---------------the current version is %d ----------------- \n',version);

resultFileName=sprintf('..\\..\\..\\result\\baidu\\ubcf\\baidu_cfulf_result_%d_%s.txt',version,date);
userSimiFileName=sprintf('..\\..\\..\\data\\baidu\\ubcfdata\\userSimiMatrix%d.mat',version);
trainSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\trainSet%d.txt',version);
testSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\testSet%d.txt',version);
userRatingMatrixFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\userRatingMatrix%d.mat',version);

coreUserFileName = sprintf('..\\..\\..\\data\\baidu\\commondata\\coreUserID.txt');
userLevelFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\userLevel.txt');
itemSimiFileName=sprintf('..\\..\\..\\data\\baidu\\ibcfdata\\itemSimiMatrix%d.mat',version);


trainSet= load(trainSetFileName);
testSet= load(testSetFileName);
load(userRatingMatrixFileName,'userRatingMatrix');

load(itemSimiFileName,'itemSimiMatrix');

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

% ��������û�ƽ�����
userAvgRating=GetAllUserAvgRating(userRatingMatrix);



%% *************һЩ��������********************
likeThreshold=4;
topKList=(10:10:100);
Neighbour=20; % ��������ھӸ���
fprintf(' current Neighbour is %d \n',Neighbour);
recListLengthRecord=[]; % ��¼һ��ÿ���û����Ƽ��б��ĳ��ȣ��������topK

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
userRatingMatrix = sparse(userRatingMatrix);
%% ����
parfor i=1:testUserCount


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
    
    totalItemSet=(1:itemCount);   
     % ȥ��testUser��trainningset���Ѿ�������item
    testUserItemSet=find(userRatingMatrix(testUserID,:)>0);
    totalItemSet=setdiff(totalItemSet,testUserItemSet);
    
    itemRankList=zeros(length(totalItemSet),2);
    itemRankList(:,1)=totalItemSet;
    
%     
% % ********** ��ͳ�汾 ****************
% 
%     finalRecList = cell(10,1);
% %     ��ÿ��item������Ԥ��
%     for p=1:length(totalItemSet)
%         targetItemID=itemRankList(p,1);
%         totalWeightedRating=0;
%         totalSimi=0;
%         
%         % �ҵ�testUser���������ڽ�N��item
%         neighbourSimiVector=zeros(length(testUserItemSet),2);
%         neighbourSimiVector(:,1)=testUserItemSet;
%         neighbourSimiVector(:,2)=itemSimiMatrix(targetItemID,testUserItemSet)';
%         % ȡ���ƶȴ���0��neighbor
%         posIdx=find(neighbourSimiVector(:,2)>0);
%         neighbourSimiVector=neighbourSimiVector(posIdx,:);     
%         % ����
%         neighbourSimiVector=-sortrows(-neighbourSimiVector,2);
%         % ȡǰN��neighbor�������˾Ͳ�����
%         realNeighbour=min(Neighbour,length(neighbourSimiVector(:,1)));
%         
% %         if realNeighbour<=3
% %             continue
% %         end
%         
%         neighbourSimiVector=neighbourSimiVector(1:realNeighbour,:);
%         for q=1:realNeighbour
%             testUserItemID=neighbourSimiVector(q,1);
% %             simi=itemSimiMatrix(targetItemID,testUserItemID);
%             simi=neighbourSimiVector(q,2);
%             rating=userRatingMatrix(testUserID,testUserItemID);
%             totalWeightedRating=totalWeightedRating+simi*rating;
%             totalSimi=totalSimi+simi;          
%         end            
%         predictRating=totalWeightedRating/totalSimi;
%         itemRankList(p,2)=predictRating;
%     end
      
    

%%    ************** ���л��汾 ***********************

    finalRecList = cell(10,1);
    % ��������� �����Ͳ���
    realNeighbour=min(Neighbour,length(testUserItemSet));
    neighbourSimiMatrix=itemSimiMatrix(itemRankList(:,1),testUserItemSet);    
    posIdx=neighbourSimiMatrix>0;
    
    % neighbour���ƶ�����
    [sortedNeighbourSimiMatrix,sortedIdx]=sort(neighbourSimiMatrix,2,'descend');
    % ȡǰN�� index
    sortedIdx=sortedIdx(:,1:realNeighbour);
    % ת����logical
    logicalIdx=zeros(length(itemRankList(:,1)),length(testUserItemSet));
    for m=1:size(logicalIdx,1)
        logicalIdx(m,sortedIdx(m,:))=1;
    end
    % ǰN����������Ϊ1
    neighbourSimiMatrix=neighbourSimiMatrix.*logicalIdx;
    % >0����Ϊ1
    neighbourSimiMatrix=neighbourSimiMatrix.*posIdx;
 
%     ����ÿ��item���õ�neighbour����������һ����ֵ ��Ԥ��
%     neighbourCount=sum(neighbourSimiMatrix>0,2);
%     nonePredictIdx=find(neighbourCount<=2);
       
    ratingVector=userRatingMatrix(testUserID,testUserItemSet);
    repRaitngMatrix=repmat(ratingVector,length(itemRankList(:,1)),1);
      
    weightedRatingMatrix=neighbourSimiMatrix.*repRaitngMatrix;
   
    sumWeightedRating=sum(weightedRatingMatrix,2);
    sumWeight=sum(neighbourSimiMatrix,2);
    itemRankList(:,2)=sumWeightedRating./sumWeight;
    
    
    % neighbour ̫�ٵ�item ������
%     itemRankList(nonePredictIdx,2)=0;
    
   %% **************************************************
    
    % ����nan
    idx1=isnan(itemRankList(:,2));
    itemRankList(idx1,2)=0;
    
    % ȡ����Ԥ�����0
    idx2=find(itemRankList(:,2)>0);
    itemRankList=itemRankList(idx2,:);
    
    %����
    itemRankList=-sortrows(-itemRankList,2);
    
      % ��¼һ��ÿ���û����Ƽ��б��ĳ��ȣ��������topK
    if size(itemRankList,1)>0
        recListLengthRecord=[recListLengthRecord size(itemRankList,1)];
    end
    
    for m = 1:10
        % ��topK�����ã������Ͳ�����
        if length(itemRankList(:,1))< topKList(m)
            realTopK=length(itemRankList(:,1));
            finalRecList{m}=itemRankList(1:realTopK,1);
        else
            finalRecList{m}=itemRankList(1:topKList(m),1);
        end
    end  

    

 

    %% ******************* ȡ�ò��Լ���Ŀ���û�ϲ����item�б�*******************
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
    
    %% ***************�����Ƽ�Ч��************************
    precisionList= [];
    recallList = [];
    for m = 1:10
        % ���Ƽ��б��Ͳ��Լ����û�ϲ����itemȡ��������Ϊhit����
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
    finalResultFileName=sprintf('..\\..\\..\\huiyiresult\\baidu\\itemCF\\final_baidu_itemCF_prf_top%d.txt',topK);

    fid = fopen(finalResultFileName,'a');
    fprintf(fid,'%f\t%f\t%f\r\n',avgPrecision(m),avgRecall(m),avgF1(m));
    fclose(fid);
end

finalDiversityFileName=sprintf('..\\..\\..\\huiyiresult\\baidu\\itemCF\\final_baidu_itemCF_diversity.txt');
finalColdUserResultFileName = sprintf('..\\..\\..\\huiyiresult\\baidu\\itemCF\\final_baidu_itemCF_colduser.txt');
finalHotUserResultFileName = sprintf('..\\..\\..\\huiyiresult\\baidu\\itemCF\\final_baidu_itemCF_hotuser.txt');


fid = fopen(finalDiversityFileName,'a');
fprintf(fid,'%f\t%f\t%f\r\n',coverage,avgILD,novelty);
fclose(fid);

fid = fopen(finalColdUserResultFileName,'a');
fprintf(fid,'%f\t%f\t%f\r\n',avgTwoEvaluation(1,2),avgTwoEvaluation(1,3),avgTwoEvaluation(1,4));
fclose(fid);

fid = fopen(finalHotUserResultFileName,'a');
fprintf(fid,'%f\t%f\t%f\r\n',avgTwoEvaluation(2,2),avgTwoEvaluation(2,3),avgTwoEvaluation(2,4));
fclose(fid);

end

toc