clear;
tic;

%% 主函数
% 用来SVD来进行评分预测，再基于评分预测进行topN推荐
date='8.26';

for version=1:1
fprintf('---------------the current version is %d ----------------- \n',version);

trainSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\trainSet%d.txt',version);
testSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\testSet%d.txt',version);
userRatingMatrixFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\userRatingMatrix%d.mat',version);
userLevelFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\userLevel.txt');
coreUserFileName = sprintf('..\\..\\..\\data\\baidu\\commondata\\coreUserID.txt');

modelFileName = sprintf('..\\..\\..\\data\\baidu\\mfdata_topN\\notW_MF_fac50_rm1_wm0.000_lamb0.100_ver%d.mat',version); %SVD模型文件名

%%********初始化****************

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

%% *************一些参数设置********************
likeThreshold=4;
topKList=(10:10:100);

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
    
    levelIdx=find(userLevel(:,1)==testUser);
    level=userLevel(levelIdx,2);
    
    
   %% *********根据评分矩阵取得用户的推荐列表****************
    predictRatingVector=predictRatingMatrix(testUserID,:);
    itemRankList=zeros(itemCount,2);
    itemRankList(:,1)=(1:itemCount);
    itemRankList(:,2)=predictRatingVector;
    
    % 依据评分用降序排列
    itemRankList=-sortrows(-itemRankList,2);
    
    % 去除testUser已经看过的
    watchedItemList=find(userRatingMatrix(testUserID,:)>0);
    [c,ia]=intersect(itemRankList(:,1),watchedItemList);
    itemRankList(ia,:)=[];
    
    finalRecList = cell(10,1);
    for m = 1:10
        % 对topK的设置，不够就不够了
        if length(itemRankList(:,1))< topKList(m)
            realTopK=length(itemRankList(:,1));
            finalRecList{m}=itemRankList(1:realTopK,1);
        else
            finalRecList{m}=itemRankList(1:topKList(m),1);
        end
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







