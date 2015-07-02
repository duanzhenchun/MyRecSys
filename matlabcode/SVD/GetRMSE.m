function rmse=GetRMSE(avgRating,bu,bi,pu,qi,uniqUserData,uniqItemData,trainSet)

testCount=size(trainSet,1);
userList=trainSet(:,1);
itemList=trainSet(:,2);
rList=trainSet(:,3);

uidList=zeros(testCount,1);
iidList=zeros(testCount,1);

parfor m=1:testCount
    user=userList(m);
    item=itemList(m);
    uidList(m)=find(uniqUserData==user);
    iidList(m)=find(uniqItemData==item);
end


predictList=avgRating+bu(uidList)+bi(iidList)+sum(pu(uidList,:).*qi(iidList,:),2);
rmse=sum((rList-predictList).^2)/testCount;
rmse=sqrt(rmse);


% rmse=0;
% for m=1:testCount
%     testcase=trainSet(m,:);
%     user=testcase(1);
%     uid=find(uniqUserData==user);
%     item=testcase(2);
%     iid=find(uniqItemData==item);
%     rating=testcase(3);
%     predict=avgRating+bu(uid)+bi(iid)+pu(uid,:)*qi(iid,:)';
%     rmse=rmse+(rating-predict)^2;
% end
% rmse=sqrt(rmse/testCount);


end
