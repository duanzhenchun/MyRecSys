clear;
tic;

%% 主函数
% 用来SVD来进行评分预测，再基于评分预测进行topN推荐
date='10.18';
version = 1;

trainSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\trainSet%d.txt',version);
testSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\testSet%d.txt',version);
userRatingMatrixFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\userRatingMatrix%d.mat',version);
resultFileName=sprintf('..\\..\\..\\result\\baidu\\socialmf_topN\\baidu_socialmf_result_%d_%s.txt',version,date);
coreUserFileName =sprintf( '..\\..\\..\\data\\baidu\\commondata\\coreUserID.txt');
userLevelFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\userLevel.txt');
modelFileName = sprintf('..\\..\\..\\data\\baidu\\socialmfdata_topN\\socialMF_iter300_fac_20rm1_wm0.100_beta0.010_lamb0.010.mat'); %SVD模型文件名
uniqueUserFileName =  sprintf('..\\..\\..\\data\\baidu\\commondata\\bigUser.mat');
itemSimiFileName=sprintf('..\\..\\..\\data\\baidu\\ibcfdata\\MF_itemSimiMatrix%d.mat',version);

%%********初始化****************
trainSet= load(trainSetFileName);
testSet=load(testSetFileName);
load(uniqueUserFileName, 'bigUser');
% load model 
load(modelFileName,'Q','P','rm');
load(userRatingMatrixFileName,'userRatingMatrix');
userLevel=load(userLevelFileName);

coreUser = load(coreUserFileName);
coreUser = unique(coreUser);

bigUser = unique(bigUser); % 专用于查询 在P中的id

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
% topKList = (10:10:100);
% for iter1 = 1 : length(topKList)
% topK=topKList(iter1);
topK=100; 
fprintf('current topK is %d \n',topK);
likeThreshold=4; 
recListLengthRecord=[]; % 记录一下每个用户的推荐列表的长度，方便调整topK

 % 记录对每个用户的推荐列表
allUserFinalRecList=cell(testUserCount,1);  
% 记录所有用户的结果
allUserEvaluation=zeros(testUserCount,4);

totalPrecision=0; totalRecall=0; 
totalCount=0; %作为最后计算precision,recall ,f1的分母
notCount = 0; % 测试集里面没有评分大于等于4的

%% 迭代
fprintf('start the iteration ... \n')
userRatingMatrix = sparse(userRatingMatrix);
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
    bigUserID = find(bigUser == testUser);
    predictRatingVector=rm + Q(bigUserID,:) * P';
    itemRatingList=zeros(itemCount,2);
    itemRatingList(:,1)=(1:itemCount);
    itemRatingList(:,2)=predictRatingVector;
    
    % 依据评分用降序排列
    itemRatingList=-sortrows(-itemRatingList,2);
    
    % 去除testUser已经看过的
    watchedItemList=find(userRatingMatrix(testUserID,:)>0);
    [c,ia]=intersect(itemRatingList(:,1),watchedItemList);
    itemRatingList(ia,:)=[];
    
    recListLengthRecord=[recListLengthRecord; [testUser size(itemRatingList,1)]];
  
    % 对topK的设置，不够就不够了
    if length(itemRatingList(:,1))<topK
        realTopK=length(itemRatingList(:,1));
        finalRecList=itemRatingList(1:realTopK,1);
    else
        finalRecList=itemRatingList(1:topK,1);
    end
           
    %% ********取得测试集中目标用户喜欢的item列表*******
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
       
    %% ***********评测推荐效果************************
    % 将推荐列表和测试集中用户喜欢的item取交集，即为hit个数
    if isempty(finalRecList)
        hitList = [];
        % 计算单个用户的precision和recall
        precision = 0;
        recall = 0 ;
    else
        [hitList,iia,iib] = intersect(finalRecList,testUserLikedItemList);
        % 计算单个用户的precision和recall
        precision=length(hitList)/topK;
        recall=length(hitList)/length(testUserLikedItemList);
    end
          
    if isnan(recall) || isnan(precision)
        disp('there is something wrong with the recall or the precision');
    end
    totalPrecision=totalPrecision+precision;
    totalRecall=totalRecall+recall;  
   
    allUserEvaluation(i,:)=[testUser,precision,recall,level];
        
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


%　分析各个Level用户的 准确率 召回率 F1
avgUserEvaluationByLevel = EvaluationAnalysis(allUserEvaluation, levelNum);

load(itemSimiFileName,'itemSimiMatrix');
 itemPopularity = GetItemPopularity(userRatingMatrix);
[coverage,avgILS,avgPopularity]  =DiversityAnalysis(allUserFinalRecList, itemCount,itemSimiMatrix,itemPopularity);
fprintf('coverage is %f, avgILS is %f,avgPopularity is %f \n ',coverage,avgILS,avgPopularity);

resultStr=sprintf('the avgPrecision is %f, the avgRecall is %f, avgF1 is %f',avgPrecision,avgRecall,avgF1);
disp(resultStr);
topKCeil= min(recListLengthRecord);

fid = fopen(resultFileName,'a');
fprintf(fid,'--------------------------- parameter ---------------------------------\r\n');
fprintf(fid,'version is %d',version);
fprintf(fid,'topK = %d, likeThreshold= %d  \r\n',topK,likeThreshold);
fprintf(fid,'the avgPrecision is %1.7f, the avgRecall is %1.7f, the avgF1 is %1.7f  \r\n',avgPrecision,avgRecall,avgF1);
fclose(fid);

% %% ******正式实验专用*************
% fid = fopen(resultFileName,'a');
% fprintf(fid,'%f\t%f\t%f\r\n',avgPrecision,avgRecall,avgF1);
% fclose(fid);



% end
toc;
        
        
        











