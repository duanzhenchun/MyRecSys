function GetRecListByInterestCircle(userInterestCircle,itemInterestCircle,userRatingMatrix)
% 兴趣小组里的给该组里的item投票，并排序,按加权平均分排序
% 返回结果是一个N*2的数组，第一列是itemID，第二列是item的加权评分
% 返回结果按评分的降序排列
itemList=zeors(length(itemInterestCircle),2);
itemList(:,1)=itemInterestCircle;

end