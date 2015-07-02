clear;
clc;
%% 获得用户的兴趣的分布情况，以此来决定取用户前百分之多少的兴趣
%% 导入数据
load ratingSomOutcome1.mat ...
    uniqUserData uniqItemData ...
    userRatingMatrix weight itemClassIndex
%% 初始化
% 百分比序列
percentList=(0.05:0.05:1);
percentWeightList=zeros(1,length(percentList));

userCount=length(uniqUserData);
itemCount=length(uniqItemData);
% 将所有用户的权重按降序排列
allSortedWeightCell=GetAllSortedWeight(weight);
% 将所有item划分到不同簇中
itemInterestCircleCell=SplitItemByInterestCircle(itemClassIndex,size(weight,1));
%% 开始计算
for i=1:length(percentList)

    interestPercent=percentList(i);
    percentWeight=0;
    for j=1:userCount

        %取得目标用户兴趣权值,考虑用户的所有>0的兴趣
        interestWeight=allSortedWeightCell{j};
        tx0=find(interestWeight(:,2)>0);
        interestWeight=interestWeight(tx0,:);
        
        % 要取得前多少个兴趣,向上去整，不超过总兴趣个数
        
        % 总兴趣个数
        totalInterestNum=size(interestWeight,1);             
        % 前百分之多少兴趣个数
        interestNum=min(ceil(totalInterestNum*interestPercent),totalInterestNum);
              
        % 计算每个兴趣涉及到的item数
        totalItemNum=0;  % 用户总的看过的item数
        tempItemNum=0;   % 前百分之多少兴趣所包含用户的看过的item个数     
        
        tx1=find(userRatingMatrix(j,:)>0);
        totalItemNum=length(tx1);
           
        for k=1:interestNum
            itemInterestCircle=itemInterestCircleCell{interestWeight(k,1)};     
            % 用户看过的item，且属于该兴趣的数目
            intersectSet=intersect(tx1,itemInterestCircle);
            intersectNum=length(intersectSet);
            tempItemNum=tempItemNum+intersectNum;
        end

        % 计算该用户前百分之多少兴趣涉及到的item总数相对于总的item的百分比
        tempPercentWeight=tempItemNum/totalItemNum;
        percentWeight=percentWeight+tempPercentWeight;
    end
    percentWeightList(i)=percentWeight/userCount;
end 

plot(percentList,percentWeightList);

