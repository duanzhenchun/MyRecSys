function userCommunityMap=GetUserCommunityMap(communityCell)
% 获取用户和社区的映射表，第1列存用户ID，第2列存每个用户所属的社区编号

lengthOfcell=cellfun('length',communityCell);
totalNodeNum=sum(lengthOfcell);
userCommunityMap=zeros(totalNodeNum,2);
userCommunityMap(:,1)=(1:totalNodeNum);

for i=1:length(communityCell)
    communityNodes=communityCell{i};
    tempindex=ismember(userCommunityMap(:,1),communityNodes);
    userCommunityMap(tempindex,2)=i;
end