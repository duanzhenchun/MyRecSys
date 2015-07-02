function [local_weight,global_weight] = CalculateWeight(userRatingMatrix,itemClassIndex,width,height)

% ���� �û��Ĵ�ָ��� �� ƽ����� �����û�����Ȥ
% ����local �� global ��Ȥ
userCount = size(userRatingMatrix, 1);
interestCount = width*height;
local_weight = zeros(interestCount, userCount);
global_weight =zeros(interestCount, userCount);

%�����ҳ�ÿ����Ȥ�У���ָ�������Ƕ���
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
    itrRecord(idx,3)= itrRecord(idx,3)./itrRecord(idx,2); % ����ƽ����
    
    ratingScaleVaraible = itrRecord(:,3)/5; 
    local_ratingNumVariable = itrRecord(:,2)/totalItemNum;
    global_ratingNumVariable = itrRecord(:,2)./maxRatingNumVector;  % ȫ�ֵı���      
    local_Fscore = 2 * local_ratingNumVariable .* ratingScaleVaraible./(local_ratingNumVariable + ratingScaleVaraible);
    local_Fscore(isnan(local_Fscore)) = 0;
    global_Fscore = 2 *  global_ratingNumVariable .* ratingScaleVaraible./( global_ratingNumVariable + ratingScaleVaraible);
    global_Fscore(isnan(global_Fscore)) = 0;
    local_weight(:,i) = local_Fscore;
    global_weight(:,i) = global_Fscore;
    
end












end