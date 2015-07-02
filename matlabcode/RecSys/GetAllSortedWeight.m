function allSortedWeightCell=GetAllSortedWeight(weight)

% 针对每个user,将其weight按降序排列
% 最后返回一个元组，记录每个user的兴趣，第1列为兴趣的编号，第2列为改用户对此兴趣的偏好程度

userNum=size(weight,2);
interestNum=size(weight,1);
allSortedWeightCell=cell(1,userNum);
for i=1:userNum
    % 第一列存序号，第二列存weight值
    interestData=zeros(interestNum,2);
    interestData(:,1)=(1:interestNum);
    interestData(:,2)=weight(:,i);
    % 按降序排列
    sortedInterestData=-sortrows(-interestData,2);
    allSortedWeightCell{i}=sortedInterestData;
end
end