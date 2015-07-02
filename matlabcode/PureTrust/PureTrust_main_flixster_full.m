clear;
tic;
%% trust aware recsys

versionSum=10;
date='10.21';

for version = 1:30
% version = 10;
fprintf('---------------the current version is %d ----------------- \n',version);


resultFileName=sprintf('..\\..\\..\\result\\flixster\\puretrust\\flixster_puretrust_result_%d_%s.txt',version,date);
trainSetFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\trainSet%d.txt',version);
testSetFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\testSet%d.txt',version);
userRatingMatrixFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\userRatingMatrix%d.mat',version);
socialTrustFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\trust200_direct%d.txt',version);
userLevelFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\userLevel%d.txt',version);
saveRecListFileName=sprintf('..\\..\\..\\data\\flixster\\puretrustdata\\recList\\reclist%d.mat',version);
coreUserFileName =sprintf( '..\\..\\..\\data\\flixster\\commondata\\coreUserID%d.txt',version);
userSocialTrustCellFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\userSocialTrustCell_direct%d.mat',version);



trainSet = load(trainSetFileName);
testSet = load(testSetFileName);
load(userRatingMatrixFileName,'userRatingMatrix');
socialTrustData=load(socialTrustFileName);
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

% 取得用户的trust列表
load(userSocialTrustCellFileName);
% userSocialTrustCell=GetUserSocialTrust(uniqUserData,socialTrustData);
% save(userSocialTrustCellFileName,'userSocialTrustCell');

% 获得所有用户平均打分
userAvgRating=GetAllUserAvgRating(userRatingMatrix);



%% *************一些参数设置********************
likeThreshold=4;
topKList=(10:10:100);
socialNeighbourNum=50;

fprintf('current socialNeigh is %d \n', socialNeighbourNum);
recListLengthRecord=[]; % 记录一下每个用户的推荐列表的长度，方便调整topK

 % 记录对每个用户的推荐列表
allUserRecInfo = cell(testUserCount,1); 

totalPrecision = zeros(1,10);
totalRecall = zeros(1,10);
totalCount=0; %作为最后计算precision,recall ,f1的分母
notCount = 0; % 测试集里面没有评分大于等于4的

fprintf('start the iteration ...')
%% 迭代
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
    
    %% 对每个用户进行推荐
    neighbourTrustVector=userSocialTrustCell{testUserID};
    neighbourTrustVector=neighbourTrustVector(1:socialNeighbourNum,:);

    % 找到这些neighbor看过的item，做成集合unionItemSet

    neighborSet=neighbourTrustVector(:,1);
    urMatrix = userRatingMatrix(neighborSet,:)>=likeThreshold;  % relevant item
    neighBourRatingSum = sum(urMatrix,1);
    unionItemSet = find(neighBourRatingSum >0);
    
    % 去除testUser在trainningset中已经看过的item
    testUserItemSet=find(userRatingMatrix(testUserID,:)>0);
    unionItemSet=setdiff(unionItemSet,testUserItemSet);
    
    finalRecList = cell(10,1);
    if isempty(unionItemSet)
        recListLengthRecord=[recListLengthRecord; [testUser 0]];
    else
         % 第一列存itemID，第二列存其平均打分
        itemRankList=zeros(length(unionItemSet),2);
        itemRankList(:,1)=unionItemSet;
        % 所有trust用户对所有item的打分
        irMatrix=userRatingMatrix(neighborSet,unionItemSet);       
        irMatrix(irMatrix>=likeThreshold) = 1;  
        zeroIndex= irMatrix==0;
        % repmat
        trustMatrix=repmat(neighbourTrustVector(:,2),1,length(unionItemSet));
        trustMatrix(zeroIndex)=0;
        % 点乘
        weightedRatingMatrix=irMatrix.*trustMatrix;
        sumWeightedRating=sum(weightedRatingMatrix,1);
        itemRankList(:,2)=sumWeightedRating;  
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
     
    end
    totalPrecision = totalPrecision + precisionList;
    totalRecall = totalRecall + recallList;
    
    
    % 记录每个用户的最终的推荐列表
    infoCell = cell(1,5);   
    infoCell{1} = testUser;
    infoCell{2} = testUserID;
    infoCell{3} = level;
    infoCell{4} = testUserLikedItemList;
    infoCell{5} = finalRecList{10};   
    allUserRecInfo{i} = infoCell;
        
    % 跑到最后的，计数+1，最后作为分母
    totalCount=totalCount+1;
end

%% *******************得到最后的结果****************************

avgPrecision=totalPrecision/totalCount;
avgRecall=totalRecall/totalCount;
avgF1=2*avgPrecision.*avgRecall./(avgPrecision+avgRecall);

% ********** final 实验用 ***************

for m =1 :10
    topK = topKList(m);
    finalResultFileName=sprintf('..\\..\\..\\result\\flixster\\puretrust\\final_flixster_puretrust_prf_top%d.txt',topK);
    fid = fopen(finalResultFileName,'a');
    fprintf(fid,'%f\t%f\t%f\r\n',avgPrecision(m),avgRecall(m),avgF1(m));
    fclose(fid);
end

allUserRecInfoFile = sprintf('..\\..\\..\\result\\flixster\\puretrust\\allUserRecInfo%d.mat',version);
save(allUserRecInfoFile,'allUserRecInfo');




end



toc






