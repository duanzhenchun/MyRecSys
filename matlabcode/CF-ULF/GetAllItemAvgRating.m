function itemAvgRating=GetAllItemAvgRating(userRatingMatrix)
% 获得所有item的平均打分
% 返回一个向量，按itemID从1到最后排列

totalRating=sum(userRatingMatrix,1);
totalUser=sum(userRatingMatrix>0,1);
zeroIdx = totalUser==0;
itemAvgRating=totalRating./totalUser;
itemAvgRating(zeroIdx)=0;
end