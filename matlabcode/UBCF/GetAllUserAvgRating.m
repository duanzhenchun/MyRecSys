function userAvgRating=GetAllUserAvgRating(userRatingMatrix)
% ��������û���ƽ�����
% ����һ����������userID��1���������

totalRating=sum(userRatingMatrix,2);
totalItem=sum(userRatingMatrix>0,2);
zeroIdx = totalItem==0;
userAvgRating=totalRating./totalItem;
userAvgRating(zeroIdx)=0;

end