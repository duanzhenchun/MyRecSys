function itermInterestCircleCell=SplitItemByInterestCircle(itemClassIndex,interestCircleNum)
% 将所有item划分到不同簇中
% 返回cell，每个cell表示一个兴趣簇，里面装着划分到该簇的item
itermInterestCircleCell=cell(1,interestCircleNum);
for i=1:length(itemClassIndex)
    circleID=itemClassIndex(i);
    itermInterestCircleCell{circleID}=[itermInterestCircleCell{circleID} i];
end
end