clear;
tic;

%% 主函数
% 用来SVD来进行评分预测，再基于评分预测进行topN推荐
version=1;

date='7.1';


trainSetFileName=sprintf('..\\..\\..\\data\\movielens\\commondata\\trainSet%d.txt',version);

testSetFileName=sprintf('..\\..\\..\\data\\movielens\\commondata\\testSet%d.txt',version);
modelFileName=sprintf('..\\..\\..\\data\\movielens\\svddata\\svdModel1%d.mat',version); %SVD模型文件名
resultFileName=sprintf('..\\..\\..\\result\\movielens\\svd\\movielens_svd_result%d_%s.txt',version,date);


%%********初始化****************

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

% bu bi 都是行向量

repbu=repmat(bu,1,itemCount);
bi = bi';
repbi=repmat(bi,userCount,1);
predictRatingMatrix=avgRating+repbu+repbi+pu*qi';

topK=50; 
likeThreshold=4; 
totalPrecision=0; totalRecall=0; 
totalCount=0;
 % 记录对每个用户的推荐列表
allUserFinalRecList=cell(testUserCount,1);  
% 记录所有用户的结果
allUserEvaluation=ones(length(testUserCount),4)*(-1);


%% 迭代
fprintf('start the iteration ...')
parfor i=1:testUserCount
%     disp(i);
    the20num=round(0.2*testUserCount);
    if mod(i,the20num)==0
        disp ('20%');
    end
    
    % 待推荐用户ID
    testUser=uniqTestUserData(i);
    % 从训练集中的uniqUserData找 testuser对应的ID
    testUserID=find(uniqUserData==testUser);
    
   %% *********根据评分矩阵取得用户的推荐列表****************
    predictRatingVector=predictRatingMatrix(testUserID,:);
    itemRatingList=zeros(itemCount,2);
    itemRatingList(:,1)=(1:itemCount);
    itemRatingList(:,2)=predictRatingVector;
    
    % 依据评分用降序排列
    itemRatingList=-sortrows(-itemRatingList,2);
    
    % 取前topK个最为最后推荐;
    finalRecList=itemRatingList(1:topK,1);
    
    if isempty(finalRecList)
        % 若推荐集合为空，则放弃推荐
        continue;
    end
    

    
    %% ********取得测试集中目标用户喜欢的item列表*******
    % 以评分大于likeThreshold表示喜欢
    
    tempIndex=find(testSet(:,1)==testUser & testSet(:,3)>=likeThreshold);
    tempItemSet=testSet(tempIndex,2);
    
    [commonItem,IA,IB]=intersect(uniqItemData,tempItemSet);
    testUserLikedItemList=IA;
    
    if isempty(testUserLikedItemList)
        % 测试集用户中没有评分大于3的item，则不考虑这个用户的推荐，放弃推荐
        continue;
    end
    
    
    %% ***********评测推荐效果************************
     % 将推荐列表和测试集中用户喜欢的item取交集，即为hit个数
    hitList=intersect(finalRecList,testUserLikedItemList);
    if isempty(finalRecList) || isempty(testUserLikedItemList)
        disp('there is something wrong with the finalRecList or the testUserLikedItemList');
        continue;
    end
    % 计算单个用户的precision和recall
    precision=length(hitList)/length(finalRecList);
    recall=length(hitList)/length(testUserLikedItemList);
    if isnan(recall) || isnan(precision)
        disp('there is something wrong with the recall or the precision');
    end
    totalPrecision=totalPrecision+precision;
    totalRecall=totalRecall+recall;
    
    
    % 记录每个用户的最终的推荐列表
    recListCell=cell(1,2);
    recListCell{1}=testUser;
    recListCell{2}=finalRecList;
    allUserFinalRecList{i}=recListCell;
       
    % 跑到最后的，计数+1，最后作为分母
    totalCount=totalCount+1;
    
end

%% #####################评价指标###########################



avgPrecision=totalPrecision/totalCount;
avgRecall=totalRecall/totalCount;
avgF1=2*avgPrecision*avgRecall/(avgPrecision+avgRecall);






%% *************将结果保存*****************


toc;
        
        
        











