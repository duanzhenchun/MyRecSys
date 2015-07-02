function interestHit=GetItemInterest(itemSet,itemClassIndex,interestCount)
% 分析itemSet中item所属的兴趣集合
% 返回每个兴趣命中的item数

% itrCount=length(unique(itemClassIndex));
itrCount=interestCount;
itrRecord=zeros(itrCount,2);
itrRecord(:,1)=(1:itrCount);
for m=1:length(itemSet)
    itemID=itemSet(m);
    tempItr=itemClassIndex(itemID);
    itrRecord(tempItr,2)=itrRecord(tempItr,2)+1;
end

interestHit=itrRecord(:,2);


end