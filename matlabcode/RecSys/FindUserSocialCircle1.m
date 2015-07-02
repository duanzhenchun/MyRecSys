function userSocialCircle=FindUserSocialCircle(testUserID,socialMatrix)
% 暂时先用这个方法，后期应该先直接对所有用都划分好，而不是临时划分
% 返回目标用户的friend 以及 trust值
% 找距离2以内的用户

%% 找到用户的社交圈
% 直接相连的用户
directUserList=find(socialMatrix(testUserID,:)==1);
directUserList=directUserList';
% 距离为2的用户
secondUserList=[];
for j=1:length(directUserList)
    tempUserList=find(socialMatrix(directUserList(j),:)==1);
    secondUserList=[secondUserList tempUserList ];
end

%% 对距离为2的用户进行处理
% 去重
secondUserList=unique(secondUserList);
% 去除testUser自己
secondUserList=setdiff(secondUserList,testUserID);
% 去除directUser
secondUserList=setdiff(secondUserList,directUserList);

%% 计算目标用户对每个neighbor的trust值
directUserCount=length(directUserList);
secondUserCount=length(secondUserList);
totalSocialUserCount=directUserCount+secondUserCount;

%  第一列存userID，第二列存trust值
userSocialCircle=zeros(totalSocialUserCount,2);
userSocialCircle(1:directUserCount,1)=directUserList;
userSocialCircle(1:directUserCount,2)=1;

userSocialCircle(directUserCount+1:totalSocialUserCount,1)=secondUserList';
userSocialCircle(directUserCount+1:totalSocialUserCount,2)=0.75;


end