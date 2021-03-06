%% item-based cf
clear;
tic;

%% ****************************** 一些初始化工作 ***********************************************
date='8.26';

versionSum=1;

for version=1:5
    
fprintf('---------------the current version is %d ----------------- \n',version);
userSimiFileName=sprintf('..\\..\\..\\data\\movielens\\ubcfdata\\userSimiMatrix%d.mat',version);
trainSetFileName=sprintf('..\\..\\..\\data\\movielens\\commondata\\trainSet%d.txt',version);
testSetFileName=sprintf('..\\..\\..\\data\\movielens\\commondata\\testSet%d.txt',version);
userRatingMatrixFileName=sprintf('..\\..\\..\\data\\movielens\\commondata\\userRatingMatrix%d.mat',version);
itemSimiFileName=sprintf('..\\..\\..\\data\\movielens\\ibcfdata\\itemSimiMatrix_cos%d.mat',version);

trainSet= load(trainSetFileName);
testSet= load(testSetFileName);
load(userRatingMatrixFileName,'userRatingMatrix');
load(itemSimiFileName,'itemSimiMatrix');

userData=trainSet(:,1);
itemData=trainSet(:,2);
uniqUserData=unique(userData);
uniqItemData=unique(itemData);
userCount=length(uniqUserData);
itemCount=length(uniqItemData);

testUserData=testSet(:,1);
uniqTestUserData=unique(testUserData);
testUserCount=length(uniqTestUserData);

% 获得所有用户平均打分
userAvgRating=GetAllUserAvgRating(userRatingMatrix);

%% *************一些参数设置********************
likeThreshold=4;
topKList=(10:10:100);
Neighbour = 10; % 依据最近邻居个数
fprintf(' current Neighbour is %d \n',Neighbour);
recListLengthRecord=[]; % 记录一下每个用户的推荐列表的长度，方便调整topK

 % 记录对每个用户的推荐列表
allUserFinalRecList=cell(testUserCount,1);  
% 记录所有用户的结果
allUserEvaluation=zeros(testUserCount,4);

totalPrecision = zeros(1,10);
totalRecall = zeros(1,10);
totalCount=0; %作为最后计算precision,recall ,f1的分母
notCount = 0; % 测试集里面没有评分大于等于4的

%% 迭代
fprintf('start the iteration ...')
userRatingMatrix = sparse(userRatingMatrix);
%% 迭代
parfor i=1:testUserCount

    the20num=round(0.2*testUserCount);
    if mod(i,the20num)==0
        disp ('20%');
    end
    % 待推荐用户ID
    testUser=uniqTestUserData(i);
    % 从训练集中的uniqUserData找 testuser对应的ID
    testUserID=find(uniqUserData==testUser);
  
    totalItemSet=(1:itemCount);   
     % 去除testUser在trainningset中已经看过的item
    testUserItemSet=find(userRatingMatrix(testUserID,:)>0);
    totalItemSet=setdiff(totalItemSet,testUserItemSet);
    
    itemRankList=zeros(length(totalItemSet),2);
    itemRankList(:,1)=totalItemSet;

%     
% % ********** 传统版本 ****************
% 
%     finalRecList = cell(10,1);
% %     对每个item做评分预测
%     for p=1:length(totalItemSet)
%         targetItemID=itemRankList(p,1);
%         totalWeightedRating=0;
%         totalSimi=0;
%         
%         % 找到testUser看过的最邻近N个item
%         neighbourSimiVector=zeros(length(testUserItemSet),2);
%         neighbourSimiVector(:,1)=testUserItemSet;
%         neighbourSimiVector(:,2)=itemSimiMatrix(targetItemID,testUserItemSet)';
%         % 取相似度大于0的neighbor
%         posIdx=find(neighbourSimiVector(:,2)>0);
%         neighbourSimiVector=neighbourSimiVector(posIdx,:);     
%         % 排序
%         neighbourSimiVector=-sortrows(-neighbourSimiVector,2);
%         % 取前N个neighbor，不够了就不够了
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
      
    

%%    ************** 并行化版本 ***********************

    finalRecList = cell(10,1);
    % 最近邻数量 不够就不够
    realNeighbour=min(Neighbour,length(testUserItemSet));
    neighbourSimiMatrix=itemSimiMatrix(itemRankList(:,1),testUserItemSet);    
    posIdx=neighbourSimiMatrix>0;
    
    % neighbour相似度排序
    [sortedNeighbourSimiMatrix,sortedIdx]=sort(neighbourSimiMatrix,2,'descend');
    % 取前N个 index
    sortedIdx=sortedIdx(:,1:realNeighbour);
    % 转换成logical
    logicalIdx=zeros(length(itemRankList(:,1)),length(testUserItemSet));
    for m=1:size(logicalIdx,1)
        logicalIdx(m,sortedIdx(m,:))=1;
    end
    % 前N个最相似设为1
    neighbourSimiMatrix=neighbourSimiMatrix.*logicalIdx;
    % >0的设为1
    neighbourSimiMatrix=neighbourSimiMatrix.*posIdx;
 
%     计算每个item可用的neighbour数量，少于一定阈值 不预测
%     neighbourCount=sum(neighbourSimiMatrix>0,2);
%     nonePredictIdx=find(neighbourCount<=2);
       
    ratingVector=userRatingMatrix(testUserID,testUserItemSet);
    repRaitngMatrix=repmat(ratingVector,length(itemRankList(:,1)),1);
      
    weightedRatingMatrix=neighbourSimiMatrix.*repRaitngMatrix;
   
    sumWeightedRating=sum(weightedRatingMatrix,2);
    sumWeight=sum(neighbourSimiMatrix,2);
    itemRankList(:,2)=sumWeightedRating./sumWeight;
    
    
    % neighbour 太少的item 不考虑
%     itemRankList(nonePredictIdx,2)=0;
    
   %% **************************************************
    
    % 处理nan
    idx1=isnan(itemRankList(:,2));
    itemRankList(idx1,2)=0;
    
    % 取评分预测大于0
    idx2=find(itemRankList(:,2)>0);
    itemRankList=itemRankList(idx2,:);
    
    %排序
    itemRankList=-sortrows(-itemRankList,2);
    
      % 记录一下每个用户的推荐列表的长度，方便调整topK
    if size(itemRankList,1)>0
        recListLengthRecord=[recListLengthRecord size(itemRankList,1)];
    end
    
    for m = 1:10
        % 对topK的设置，不够就不够了
        if length(itemRankList(:,1))< topKList(m)
            realTopK=length(itemRankList(:,1));
            finalRecList{m}=itemRankList(1:realTopK,1);
        else
            finalRecList{m}=itemRankList(1:topKList(m),1);
        end
    end  

    %% ******************* 取得测试集中目标用户喜欢的item列表*******************
    % 以评分大于likeThreshold表示喜欢
    tempIndex=find(testSet(:,1)==testUser & testSet(:,3)>=likeThreshold);
    tempItemSet=testSet(tempIndex,2);
    
    [commonItem,IA,IB]=intersect(uniqItemData,tempItemSet);
    testUserLikedItemList=IA;
    
    if isempty(testUserLikedItemList)
        % 测试集用户中没有评分大于3的item，则不考虑这个用户的推荐，放弃推荐
        notCount = notCount+1;
        continue;
    end
    
    
    %% ***************评测推荐效果************************
    precisionList= [];
    recallList = [];
    for m = 1:10
        % 将推荐列表和测试集中用户喜欢的item取交集，即为hit个数
        if isempty(finalRecList{m})
            hitList = [];
            % 计算单个用户的precision和recall
            precision = 0;
            recall = 0 ;
        else
            [hitList,iia,iib] = intersect(finalRecList{m},testUserLikedItemList);
            % 计算单个用户的precision和recall
            precision=length(hitList)/topKList(m);
            recall=length(hitList)/length(testUserLikedItemList);
        end

        if isnan(recall) || isnan(precision)
            disp('there is something wrong with the recall or the precision');
        end
        precisionList = [precisionList precision];
        recallList = [recallList recall];
     
        if m==10
            allUserEvaluation(i,:)=[testUser,precision,recall,1];
        end
    end
    totalPrecision = totalPrecision + precisionList;
    totalRecall = totalRecall + recallList;
    
    % 记录每个用户的最终的推荐列表
    recListCell=cell(1,2);
    recListCell{1}=testUser;
    recListCell{2}=finalRecList{5};
    allUserFinalRecList{i}=recListCell;
       
    % 跑到最后的，计数+1，最后作为分母
    totalCount=totalCount+1;
end

%% #####################评价指标###########################


avgPrecision=totalPrecision/totalCount;
avgRecall=totalRecall/totalCount;
avgF1=2*avgPrecision.*avgRecall./(avgPrecision+avgRecall);



itemDistMatrix = 1 - itemSimiMatrix;
clear itemSimiMatrix;
itemPopularity = GetItemPopularity(userRatingMatrix);
[coverage,avgILD,novelty] = DiversityAnalysis(allUserFinalRecList,itemDistMatrix,itemPopularity,itemCount,userCount);
avgILD = avgILD/2;
fprintf('coverage is %f, avgILD is %f,novelty is %f \n ',coverage,avgILD,novelty);
clear itemDistMatrix;

% % 计算topK的天花板，超过哪个值，就不能再取了
% topKCeil= min(recListLengthRecord);

%% *************将结果保存*****************

% **********final 实验用 ***************

for m = 1:5
    topK = topKList(m);
    finalResultFileName=sprintf('..\\..\\..\\result\\movielens\\itemCF\\final_movielens_itemCF_prf_top%d.txt',topK);
%     finalResultFileName=sprintf('..\\..\\..\\result\\movielens\\itemCF\\final_movielens_itemCF_prf_top%d_neighbor%d.txt',topK,Neighbour);
    fid = fopen(finalResultFileName,'a');
    fprintf(fid,'%f\t%f\t%f\r\n',avgPrecision(m),avgRecall(m),avgF1(m));
    fclose(fid);
end

finalDiversityFileName=sprintf('..\\..\\..\\result\\movielens\\itemCF\\final_movielens_itemCF_diversity.txt');
fid = fopen(finalDiversityFileName,'a');
fprintf(fid,'%f\t%f\t%f\r\n',coverage,avgILD,novelty);
fclose(fid);



end

toc