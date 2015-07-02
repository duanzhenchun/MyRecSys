% ����һ�����õ����ݵ����

% ��ȡѵ������Ϣ
trainSet= load('..\..\data\mydata1\set\TrainSet1.txt');
userData=trainSet(:,1);
itemData=trainSet(:,2);
uniqUserData=unique(userData);
uniqItemData=unique(itemData);
userCount=length(uniqUserData);
itemCount=length(uniqItemData);
ratingData=trainSet(:,3);
ratingCount=length(ratingData);

% �����û��Ĵ�ֵĸ�����ͳ�ƾ���
userRatingCountMatrix=zeros(userCount,2);
for i=1:userCount
    targetUser=uniqUserData(i);
    [tx,ty]=find(trainSet(:,1)==targetUser);
    targetUserRatingCount=length(tx);
    userRatingCountMatrix(i,1)=targetUser;
    userRatingCountMatrix(i,2)=targetUserRatingCount;
%     targetUserRating=trainSet(tx,:);

    
end