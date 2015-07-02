function similarity=GetUserSimilarity(commonItemSet,useri,userj,userRatingMatrix,userAvgRating)
% 计算用户之间的相似度
% 采用pearson公式

% if length(commonItemSet)==1
%     similarity=-1;
%     return
% end

userIVector=userRatingMatrix(useri,:);
userJVector=userRatingMatrix(userj,:);

userIAvgRating=userAvgRating(useri);
userJAvgRating=userAvgRating(userj);

userIBias=userIVector(commonItemSet)-userIAvgRating;
userJBias=userJVector(commonItemSet)-userJAvgRating;

twoUserTotalBias=sum(userIBias.*userJBias);
userITotalBias=sum(userIBias.*userIBias)^(1/2);
userJTotalBias=sum(userJBias.*userJBias)^(1/2);

similarity=twoUserTotalBias/(userITotalBias*userJTotalBias);




end