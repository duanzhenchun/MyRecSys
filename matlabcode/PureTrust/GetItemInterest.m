function interestHit=GetItemInterest(itemSet,itemClassIndex,interestCount)
% ����itemSet��item��������Ȥ����
% ����ÿ����Ȥ���е�item��

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