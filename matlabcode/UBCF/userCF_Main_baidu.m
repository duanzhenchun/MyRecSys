clear;
tic
%% user-based CF

%% ******************************一些初始化工作 ***********************************************
date='10.18';
versionSum=1;

for version=1:10

fprintf('---------------the current version is %d ----------------- \n',version);

resultFileName=sprintf('..\\..\\..\\result\\baidu\\ubcf\\baidu_cfulf_result_%d_%s.txt',version,date);
userSimiFileName=sprintf('..\\..\\..\\data\\baidu\\ubcfdata\\userSimiMatrix%d.mat',version);
trainSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\trainSet%d.txt',version);
testSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\testSet%d.txt',version);
userRatingMatrixFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\userRatingMatrix%d.mat',version);
userLevelFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\userLevel.txt');
coreUserFileName = sprintf('..\\..\\..\\data\\baidu\\commondata\\coreUserID.txt');



trainSet= load(trainSetFileName);
load(userSimiFileName,'userSimiMatrix');
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

% 获得所有用户平均打分
userAvgRating=GetAllUserAvgRating(userRatingMatrix);

%% *************一些参数设置********************
likeThreshold=4;
topKList=(10:10:100);
Neighbour=20; % 依据最近邻居个数
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

parfor i=1:testUserCount

    the20num = round(0.2*testUserCount);
    if mod(i,the20num)==0
        disp ('20%');
    end

    % 待推荐用户ID
    testUser=uniqTestUserData(i);
    % 从训练集中的uniqUserData找 testuser对应的ID
    testUserID=find(uniqUserData==testUser);
    
    levelIdx=find(userLevel(:,1)==testUser);
    level=userLevel(levelIdx,2);
    
    %% 对每个用户进行推荐
    
    % 找到用户的相似度向量
    testUserSimiVector = userSimiMatrix(i,:);
    ucount = length(testUserSimiVector);
    
    % 第1列是userID，第2列是相似度值
    neighbourSimiVector=zeros(ucount,2);
    neighbourSimiVector(:,1)=(1:ucount);
    neighbourSimiVector(:,2)=testUserSimiVector';
    
     % 取相似度大于0的 neighbor
    posIdx=find(neighbourSimiVector(:,2)>0);
    neighbourSimiVector=neighbourSimiVector(posIdx,:);
    % 排序,降序
    neighbourSimiVector=-sortrows(-neighbourSimiVector,2);
 
    % 取前N个neighbor
    %neighbor不够就不够了
    realNeighbour=min(Neighbour,length(neighbourSimiVector(:,1)));
    neighbourSimiVector=neighbourSimiVector(1:realNeighbour,:);
       
    % 找到这些neighbor看过的item，做成集合unionItemSet
    neighborSet=neighbourSimiVector(:,1);
    urMatrix = userRatingMatrix(neighborSet,:)>0;   % relevant item
    neighBourRatingSum = sum(urMatrix,1);
    unionItemSet = find(neighBourRatingSum >0);
        
    % 去除testUser在trainningset中已经看过的item
    testUserItemSet=find(userRatingMatrix(testUserID,:)>0);
    unionItemSet=setdiff(unionItemSet,testUserItemSet);
  
    
    %% ************** 并行化方法 ***************************
    
    finalRecList = cell(10,1);
    if isempty(unionItemSet)
        recListLengthRecord=[recListLengthRecord; [testUser 0]];
    else
        % 第一列存itemID，第二列存其平均打分
        itemRankList=zeros(length(unionItemSet),2);
        itemRankList(:,1)=unionItemSet;
        % 所有相似用户对所有item的打分
        irMatrix=userRatingMatrix(neighbourSimiVector(:,1),unionItemSet);
        zeroIndex= irMatrix==0;
        % 所有相似用户的平均打分
        irAvgMatrix=repmat(userAvgRating(neighbourSimiVector(:,1)),1,length(unionItemSet));
        irAvgMatrix(zeroIndex)=0;
        % 每个用户都减去其平均打分
%         irMatrix=irMatrix-irAvgMatrix;
        % repmat
        simiMatrix=repmat(neighbourSimiVector(:,2),1,length(unionItemSet));  
        simiMatrix(zeroIndex)=0;
        % 点乘
        weightedRatingMatrix=irMatrix.*simiMatrix;
        sumWeightedRating=sum(weightedRatingMatrix,1);
        sumWeight=sum(simiMatrix,1);
        itemRankList(:,2)=sumWeightedRating./sumWeight;
        % 加上testUser的平均打分
%         testUserAvgRating=userAvgRating(testUserID);
%         itemRankList(:,2)=itemRankList(:,2)+testUserAvgRating;
         %排序
        itemRankList=-sortrows(-itemRankList,2);
         % 记录一下每个用户的推荐列表的长度，方便调整topK 
        recListLengthRecord=[recListLengthRecord; [testUser size(itemRankList,1)]];
        
        for m = 1:10
            % 对topK的设置，不够就不够了
            if length(itemRankList(:,1))< topKList(m)
                realTopK=length(itemRankList(:,1));
                finalRecList{m}=itemRankList(1:realTopK,1);
            else
                finalRecList{m}=itemRankList(1:topKList(m),1);
            end
        end  
           
    end
    %%*****************************************
    
    
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
            allUserEvaluation(i,:)=[testUser,precision,recall,level];
        end
    end
    totalPrecision = totalPrecision + precisionList;
    totalRecall = totalRecall + recallList;
    
    % 记录每个用户的最终的推荐列表
    recListCell=cell(1,2);
    recListCell{1}=testUser;
    recListCell{2}=finalRecList{10};
    allUserFinalRecList{i}=recListCell;
       
    % 跑到最后的，计数+1，最后作为分母
    totalCount=totalCount+1;
end

%% #####################评价指标###########################


avgPrecision=totalPrecision/totalCount;
avgRecall=totalRecall/totalCount;
avgF1=2*avgPrecision.*avgRecall./(avgPrecision+avgRecall);

%　分析各个Level用户的 准确率 召回率 F1
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

% 计算topK的天花板，超过哪个值，就不能再取了
topKCeil= min(recListLengthRecord);

%% *************将结果保存*****************

% **********final 实验用 ***************

for m =1 :10
    topK = topKList(m);
    finalResultFileName=sprintf('..\\..\\..\\huiyiresult\\baidu\\userCF\\final_baidu_userCF_prf_top%d.txt',topK);

    fid = fopen(finalResultFileName,'a');
    fprintf(fid,'%f\t%f\t%f\r\n',avgPrecision(m),avgRecall(m),avgF1(m));
    fclose(fid);
end

finalDiversityFileName=sprintf('..\\..\\..\\huiyiresult\\baidu\\userCF\\final_baidu_userCF_diversity.txt');
finalColdUserResultFileName = sprintf('..\\..\\..\\huiyiresult\\baidu\\userCF\\final_baidu_userCF_colduser.txt');
finalHotUserResultFileName = sprintf('..\\..\\..\\huiyiresult\\baidu\\userCF\\final_baidu_userCF_hotuser.txt');


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