function userSocialCircle=FindUserSocialCircle(testUserID,userCommunityMap,trustMatrixCommuMapCell,trustNodeMapCell)
% userCommunityMap存的是每个用户所属的社区编号
% 根据目标用户和社区的映射关系，找到与目标用户在同一社区的friend
% 返回目标用户的friend 以及 trust值

%% 找到用户的社交圈ID
idx=find(userCommunityMap(:,1)==testUserID);
commID=userCommunityMap(idx,2);

%% 获取trustMatrix
trustMatrix=trustMatrixCommuMapCell{commID};

%% 获取该社区内用户ID的映射，第1列为映射后的，从1开始，第2列为之前的乱序
trustNodeMap=trustNodeMapCell{commID};

%% 进行映射并计算目标用户对每个neighbor的trust值

mappedTestUserID=trustNodeMap(find(trustNodeMap(:,2)==testUserID),1);
trustVector=trustMatrix(mappedTestUserID,:);

friendList=trustNodeMap(:,2);
% 去除testUserID,不包含自己
friendList=setdiff(friendList,testUserID);
friendCount=length(friendList);

%  第一列存userID，第二列存trust值
userSocialCircle=zeros(friendCount,2);
userSocialCircle(:,1)=friendList;
for i=1:friendCount
    friendID=userSocialCircle(i,1);
    mappedFriendID=trustNodeMap(find(trustNodeMap(:,2)==friendID),1);
    trustValue=trustVector(mappedFriendID);
    userSocialCircle(i,2)=trustValue;
end
    
 
end