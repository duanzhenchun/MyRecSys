function interestRecList=GetRecListByInterestCircle2(testUserID,userInterestCircle,itemInterestCircle,userRatingMatrix,globalPrefer,beta)
% 利用用户的单个兴趣圈来产生推荐
% 返回一个降序排列的推荐列表，包括item的序号和其平均打分

% recThreshold   基于最终兴趣进行推荐时，在每个兴趣圈里，预测评分要大于这个阈值才会被推荐


% ******** 筛选interest user *****************************
upBoundary = globalPrefer + beta;
downBoundary =  globalPrefer - beta;

finalIdx = find( userInterestCircle(:,2)>=downBoundary & userInterestCircle(:,2)<=upBoundary );
userInterestCircle = userInterestCircle(finalIdx,:);

% ******************************* 取得每个兴趣用户的相似度 *****************************

% 计算targetUser 对兴趣小组每个人的 兴趣接受度
itrUserCount=length(userInterestCircle);

% % ############################
% %  ## special update ##
% userInterestCircle(:,2) = beta - abs( userInterestCircle(:,2) - globalPrefer);
% % ###########################

% neighbor的权重 = 兴趣相似度*对兴趣圈子的归属度
simiWeight=zeros(itrUserCount,2);
simiWeight(:,1)=userInterestCircle(:,1);
% simiWeight(:,2)=userInterestCircle(:,2);
% simiWeight(:,2)=interestAccep(:,2);
simiWeight(:,2)=userInterestCircle(:,2);


% 去除 相似度为 0的 
idx = find(simiWeight(:,2) >0);
simiWeight = simiWeight(idx,:);

% 排序
simiWeight=-sortrows(-simiWeight,2);

% 依据simiWeight 取前百分之 circlePeopleCutRate 的neighbor进行评价

% circlePeopleCutRate = 0.3;
% neighbourNum=ceil(size(simiWeight,1)*circlePeopleCutRate);
% neighbourNum=min(ceil(size(simiWeight,1)*circlePeopleCutRate),500);

% neighbourNum = size(simiWeight,1);
neighbourNum = min(size(simiWeight,1),50);

simiWeight=simiWeight(1:neighbourNum,:);


%********************************基于兴趣用户进行协同过滤********************************

% % 
% % 第一列存itemID，第二列存其平均打分
% itemAvgWeightRating=zeros(length(itemInterestCircle),2);
% count=0;
% for i=1:length(itemInterestCircle)
%     
%     itemID=itemInterestCircle(i);
%     totalWeightRating=0;
%     totalWeight=0;
%     for j=1:size(simiWeight,1)
%         simiUserID=simiWeight(j,1);
%         weight=simiWeight(j,2);
%         rt=userRatingMatrix(simiUserID,itemID);
%         if rt==0
%             continue;
%         else
%             totalWeightRating=totalWeightRating+rt*weight;
%             totalWeight=totalWeight+weight;
%         end
%     end
%     
%     % 如果没有圈子里没有用户对这个item打分
%     if totalWeightRating==0
%        % 因为totalWeight也是0，所以直接赋0
%        avgrt=0;    
%        count=count+1;
%     else
%         % 算加权平均值
%         avgrt=totalWeightRating/totalWeight;
%     end
%     itemAvgWeightRating(i,1)=itemID;
%     itemAvgWeightRating(i,2)=avgrt; 
% 
% end



% 第一列存itemID，第二列存其加权平均打分
itemAvgWeightRating=zeros(length(itemInterestCircle),3);
itemAvgWeightRating(:,1)=itemInterestCircle;
% 所有兴趣用户对所有item的打分
irMatrix=userRatingMatrix(simiWeight(:,1),itemInterestCircle);
% 0 index
% irMatrix(irMatrix>0) = 1;
zeroIndex = irMatrix==0;

simiMatrix=repmat(simiWeight(:,2),1,length(itemInterestCircle));
simiMatrix(zeroIndex)=0;
% 点乘
weightedRatingMatrix=irMatrix.*simiMatrix;
sumWeightedRating=sum(weightedRatingMatrix,1);
itemAvgWeightRating(:,2)=sumWeightedRating;
% sumWeight=sum(simiMatrix,1);
% itemAvgWeightRating(:,2)=sumWeightedRating./sumWeight;

% commonMatrix = irMatrix>0;
% commonMatrix(zeroIndex) = 0;
% commonVec = sum(commonMatrix,1);

% itemAvgWeightRating(:,2) = itemAvgWeightRating(:,2) / ( sum(simiWeight(:,2)) );
itemAvgWeightRating(:,2) = itemAvgWeightRating(:,2) / ( 5 * sum(simiWeight(:,2)));

% itemAvgWeightRating(:,3)  = commonVec';

% 去除nan
idx=isnan(itemAvgWeightRating(:,2));
itemAvgWeightRating(idx,2)=0;


% 排序
itemAvgWeightRating=-sortrows(-itemAvgWeightRating,2);
% 利用recThreshold 过滤一些评分不太高的item, *** 可以尝试加上 = 号 ***


% kx2=find(itemAvgWeightRating(:,2)>=recThreshold);
% itemAvgWeightRating=itemAvgWeightRating(kx2,:);


interestRecList=itemAvgWeightRating;

end