function [local_weight,global_weight] = CalculateWeight(userRatingMatrix,itemClassIndex,width,height)

% 依据 用户的打分个数 和 平均打分 计算用户的兴趣
% 包括local 和 global 兴趣
userCount = size(userRatingMatrix, 1);
interestCount = width*height;
local_weight = zeros(interestCount, userCount);
global_weight =zeros(interestCount, userCount);

%首先找出每个兴趣中，打分个数最多是多少
maxRatingNumVector = zeros(interestCount, 1);
parfor i=1: interestCount
    intItemCollec = find( itemClassIndex == i);
    ratMatrix = userRatingMatrix(:,intItemCollec)>0;
    ratNum = sum(ratMatrix,2);
    maxRatNum = max(ratNum);
    maxRatingNumVector(i) = maxRatNum;
end

parfor i=1:userCount

    itemSet=find(userRatingMatrix(i,:)>0);
    totalItemNum = length(itemSet);
    itrRecord=zeros(interestCount,3);
    itrRecord(:,1)=(1:interestCount);
    for m=1:totalItemNum
        itemID=itemSet(m);
        tempItr=itemClassIndex(itemID);
        itrRecord(tempItr,2)=itrRecord(tempItr,2)+1;
        itrRecord(tempItr,3)=itrRecord(tempItr,3)+userRatingMatrix(i,itemID);
    end
    idx = find(itrRecord(:,2)>0);
    itrRecord(idx,3)= itrRecord(idx,3)./itrRecord(idx,2); % 先求平均分
    
    ratingScaleVaraible = itrRecord(:,3)/5; 
    local_ratingNumVariable = itrRecord(:,2)/totalItemNum;
    global_ratingNumVariable = itrRecord(:,2)./maxRatingNumVector;  % 全局的比例      
    local_Fscore = 2 * local_ratingNumVariable .* ratingScaleVaraible./(local_ratingNumVariable + ratingScaleVaraible);
    local_Fscore(isnan(local_Fscore)) = 0;
    global_Fscore = 2 *  global_ratingNumVariable .* ratingScaleVaraible./( global_ratingNumVariable + ratingScaleVaraible);
    global_Fscore(isnan(global_Fscore)) = 0;
    local_weight(:,i) = local_Fscore;
    global_weight(:,i) = global_Fscore;
    
end












end