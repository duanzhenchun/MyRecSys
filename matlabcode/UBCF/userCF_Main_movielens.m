clear;
tic
%% user-based CF

%% ******************************һЩ��ʼ������ ***********************************************

versionSum=1;

for version=1:5

fprintf('---------------the current version is %d ----------------- \n',version);

userSimiFileName=sprintf('..\\..\\..\\data\\movielens\\ubcfdata\\userSimiMatrix%d.mat',version);
trainSetFileName=sprintf('..\\..\\..\\data\\movielens\\commondata\\trainSet%d.txt',version);
testSetFileName=sprintf('..\\..\\..\\data\\movielens\\commondata\\testSet%d.txt',version);
userRatingMatrixFileName=sprintf('..\\..\\..\\data\\movielens\\commondata\\userRatingMatrix%d.mat',version);

trainSet= load(trainSetFileName);
load(userSimiFileName,'userSimiMatrix');
testSet= load(testSetFileName);
load(userRatingMatrixFileName,'userRatingMatrix');


userData=trainSet(:,1);
itemData=trainSet(:,2);
uniqUserData=unique(userData);
uniqItemData=unique(itemData);
userCount=length(uniqUserData);
itemCount=length(uniqItemData);

testUserData=testSet(:,1);
uniqTestUserData=unique(testUserData);
testUserCount=length(uniqTestUserData);

% ��������û�ƽ�����
userAvgRating=GetAllUserAvgRating(userRatingMatrix);

%% *************һЩ��������********************
likeThreshold=4;
topKList=(10:10:100);
Neighbour=10; % ��������ھӸ���
fprintf(' current Neighbour is %d \n',Neighbour);
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
userRatingMatrix = sparse(userRatingMatrix);

parfor i=1:testUserCount

    the20num = round(0.2*testUserCount);
    if mod(i,the20num)==0
        disp ('20%');
    end

    % ���Ƽ��û�ID
    testUser=uniqTestUserData(i);
    % ��ѵ�����е�uniqUserData�� testuser��Ӧ��ID
    testUserID=find(uniqUserData==testUser);
    

    %% ��ÿ���û������Ƽ�
    
    % �ҵ��û������ƶ�����
    testUserSimiVector = userSimiMatrix(i,:);
    ucount = length(testUserSimiVector);
    
    % ��1����userID����2�������ƶ�ֵ
    neighbourSimiVector=zeros(ucount,2);
    neighbourSimiVector(:,1)=(1:ucount);
    neighbourSimiVector(:,2)=testUserSimiVector';
    
     % ȡ���ƶȴ���0�� neighbor
    posIdx=find(neighbourSimiVector(:,2)>0);
    neighbourSimiVector=neighbourSimiVector(posIdx,:);
    % ����,����
    neighbourSimiVector=-sortrows(-neighbourSimiVector,2);
 
    % ȡǰN��neighbor
    %neighbor�����Ͳ�����
    realNeighbour = min(Neighbour,length(neighbourSimiVector(:,1)));
    neighbourSimiVector = neighbourSimiVector(1:realNeighbour,:);
       
    % �ҵ���Щneighbor������item�����ɼ���unionItemSet
    neighborSet=neighbourSimiVector(:,1);
    urMatrix = userRatingMatrix(neighborSet,:)>0;   % relevant item
    neighBourRatingSum = sum(urMatrix,1);
    unionItemSet = find(neighBourRatingSum >0);
        
    % ȥ��testUser��trainningset���Ѿ�������item
    testUserItemSet=find(userRatingMatrix(testUserID,:)>0);
    unionItemSet=setdiff(unionItemSet,testUserItemSet);
  
    
    %% ************** ���л����� ***************************
    
    finalRecList = cell(10,1);
    if isempty(unionItemSet)
        recListLengthRecord=[recListLengthRecord; [testUser 0]];
    else
        % ��һ�д�itemID���ڶ��д���ƽ�����
        itemRankList=zeros(length(unionItemSet),2);
        itemRankList(:,1)=unionItemSet;
        % ���������û�������item�Ĵ��
        irMatrix=userRatingMatrix(neighbourSimiVector(:,1),unionItemSet);
        zeroIndex= irMatrix==0;
        % ���������û���ƽ�����
        irAvgMatrix=repmat(userAvgRating(neighbourSimiVector(:,1)),1,length(unionItemSet));
        irAvgMatrix(zeroIndex)=0;
        % ÿ���û�����ȥ��ƽ�����
%         irMatrix=irMatrix-irAvgMatrix;
        % repmat
        simiMatrix=repmat(neighbourSimiVector(:,2),1,length(unionItemSet));  
        simiMatrix(zeroIndex)=0;
        % ���
        weightedRatingMatrix=irMatrix.*simiMatrix;
        sumWeightedRating=sum(weightedRatingMatrix,1);
        sumWeight=sum(simiMatrix,1);
        itemRankList(:,2)=sumWeightedRating./sumWeight;
        % ����testUser��ƽ�����
%         testUserAvgRating=userAvgRating(testUserID);
%         itemRankList(:,2)=itemRankList(:,2)+testUserAvgRating;
         %����
        itemRankList=-sortrows(-itemRankList,2);
         % ��¼һ��ÿ���û����Ƽ��б�ĳ��ȣ��������topK 
        recListLengthRecord=[recListLengthRecord; [testUser size(itemRankList,1)]];
        
        for m = 1:10
            % ��topK�����ã������Ͳ�����
            if length(itemRankList(:,1))< topKList(m)
                realTopK=length(itemRankList(:,1));
                finalRecList{m}=itemRankList(1:realTopK,1);
            else
                finalRecList{m}=itemRankList(1:topKList(m),1);
            end
        end  
           
    end
    %%*****************************************
    
    
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
     
        if m == 10
            allUserEvaluation(i,:)=[testUser,precision,recall,1];
        end
    end
    totalPrecision = totalPrecision + precisionList;
    totalRecall = totalRecall + recallList;
    
    % ��¼ÿ���û������յ��Ƽ��б�
    recListCell=cell(1,2);
    recListCell{1}=testUser;
    recListCell{2}=finalRecList{5};
    allUserFinalRecList{i}=recListCell;
       
    % �ܵ����ģ�����+1�������Ϊ��ĸ
    totalCount=totalCount+1;
end

%% #####################����ָ��###########################


avgPrecision=totalPrecision/totalCount;
avgRecall=totalRecall/totalCount;
avgF1=2*avgPrecision.*avgRecall./(avgPrecision+avgRecall);


itemSimiFileName = sprintf('..\\..\\..\\data\\movielens\\ibcfdata\\itemSimiMatrix_cos%d.mat',version);
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
for m = 1:5
    topK = topKList(m);
    finalResultFileName=sprintf('..\\..\\..\\result\\movielens\\userCF\\final_movielens_userCF_prf_top%d.txt',topK);
%     finalResultFileName=sprintf('..\\..\\..\\result\\movielens\\userCF\\final_movielens_userCF_prf_top%d_neighbor%d.txt',topK,Neighbour);
    fid = fopen(finalResultFileName,'a');
    fprintf(fid,'%f\t%f\t%f\r\n',avgPrecision(m),avgRecall(m),avgF1(m));
    fclose(fid);
end

finalDiversityFileName = sprintf('..\\..\\..\\result\\movielens\\userCF\\final_movielens_userCF_diversity.txt');

fid = fopen(finalDiversityFileName,'a');
fprintf(fid,'%f\t%f\t%f\r\n',coverage,avgILD,novelty);
fclose(fid);





end



toc