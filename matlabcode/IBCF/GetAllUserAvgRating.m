function userAvgRating=GetAllUserAvgRating(userRatingMatrix)
% 获得所有用户的平均打分
% 返回一个向量，按userID从1到最后排列

totalRating=sum(userRatingMatrix,2);
totalItem=sum(userRatingMatrix>0,2);
zeroIdx = totalItem==0;
userAvgRating=totalRating./totalItem;
userAvgRating(zeroIdx)=0;

end