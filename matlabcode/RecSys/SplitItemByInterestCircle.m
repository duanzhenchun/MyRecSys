function itermInterestCircleCell=SplitItemByInterestCircle(itemClassIndex,interestCircleNum)
% 将所有item划分到不同簇中
% 返回cell，每个cell表示一个兴趣簇，里面装着划分到该簇的item
itermInterestCircleCell=cell(interestCircleNum,1);
for i=1:interestCircleNum
    circleID=i;
    itemSet=find(itemClassIndex==circleID);
    itermInterestCircleCell{circleID}=itemSet;   
end

end