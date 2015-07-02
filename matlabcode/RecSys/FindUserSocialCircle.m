function userSocialCircle=FindUserSocialCircle(testUserID,userCommunityMap,trustMatrixCommuMapCell,trustNodeMapCell)
% userCommunityMap�����ÿ���û��������������
% ����Ŀ���û���������ӳ���ϵ���ҵ���Ŀ���û���ͬһ������friend
% ����Ŀ���û���friend �Լ� trustֵ

%% �ҵ��û����罻ȦID
idx=find(userCommunityMap(:,1)==testUserID);
commID=userCommunityMap(idx,2);

%% ��ȡtrustMatrix
trustMatrix=trustMatrixCommuMapCell{commID};

%% ��ȡ���������û�ID��ӳ�䣬��1��Ϊӳ���ģ���1��ʼ����2��Ϊ֮ǰ������
trustNodeMap=trustNodeMapCell{commID};

%% ����ӳ�䲢����Ŀ���û���ÿ��neighbor��trustֵ

mappedTestUserID=trustNodeMap(find(trustNodeMap(:,2)==testUserID),1);
trustVector=trustMatrix(mappedTestUserID,:);

friendList=trustNodeMap(:,2);
% ȥ��testUserID,�������Լ�
friendList=setdiff(friendList,testUserID);
friendCount=length(friendList);

%  ��һ�д�userID���ڶ��д�trustֵ
userSocialCircle=zeros(friendCount,2);
userSocialCircle(:,1)=friendList;
for i=1:friendCount
    friendID=userSocialCircle(i,1);
    mappedFriendID=trustNodeMap(find(trustNodeMap(:,2)==friendID),1);
    trustValue=trustVector(mappedFriendID);
    userSocialCircle(i,2)=trustValue;
end
    
 
end