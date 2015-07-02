function userCommunityMap=GetUserCommunityMap(communityCell)
% ��ȡ�û���������ӳ�����1�д��û�ID����2�д�ÿ���û��������������

lengthOfcell=cellfun('length',communityCell);
totalNodeNum=sum(lengthOfcell);
userCommunityMap=zeros(totalNodeNum,2);
userCommunityMap(:,1)=(1:totalNodeNum);

for i=1:length(communityCell)
    communityNodes=communityCell{i};
    tempindex=ismember(userCommunityMap(:,1),communityNodes);
    userCommunityMap(tempindex,2)=i;
end