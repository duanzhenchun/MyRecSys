function itemAvgRating=GetAllItemAvgRating(userRatingMatrix)
% �������item��ƽ�����
% ����һ����������itemID��1���������

totalRating=sum(userRatingMatrix,1);
totalUser=sum(userRatingMatrix>0,1);
zeroIdx = totalUser==0;
itemAvgRating=totalRating./totalUser;
itemAvgRating(zeroIdx)=0;
end