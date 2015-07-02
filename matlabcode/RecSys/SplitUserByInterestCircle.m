function interestCircleCell=SplitUserByInterestCircle(weight,interestCircleThreshold)
% 对每个用户，若其对某个兴趣有权值，当权值大于等于一定阈值时，将用户划分到那个簇
% 返回一个元组，每一个cell表示归属到该兴趣内的用户ID和weight
% 并且每个cell都按权值的降序排列

interestCircleNum=size(weight,1);
interestCircleCell=cell(interestCircleNum,1);

for i=1:interestCircleNum
    tempWeight=weight(i,:);
    idx=find(tempWeight>interestCircleThreshold);
    if ~isempty(idx)
        interestCircle=zeros(length(idx),2);
        interestCircle(:,1)=idx;  %user id
        interestCircle(:,2)=tempWeight(idx);
        interestCircle=-sortrows(-interestCircle,2); %按权值降序排列
        interestCircleCell{i}=interestCircle;
    end
end


end