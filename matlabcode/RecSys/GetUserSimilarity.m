function similarity=GetUserSimilarity(commonItemSet,useri,userj,userRatingMatrix,userAvgRating)
% �����û�֮������ƶ�
% ����pearson��ʽ

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