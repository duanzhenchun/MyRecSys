function userSocialCircle=FindUserSocialCircle(testUserID,socialMatrix)
% ��ʱ�����������������Ӧ����ֱ�Ӷ������ö����ֺã���������ʱ����
% ����Ŀ���û���friend �Լ� trustֵ
% �Ҿ���2���ڵ��û�

%% �ҵ��û����罻Ȧ
% ֱ���������û�
directUserList=find(socialMatrix(testUserID,:)==1);
directUserList=directUserList';
% ����Ϊ2���û�
secondUserList=[];
for j=1:length(directUserList)
    tempUserList=find(socialMatrix(directUserList(j),:)==1);
    secondUserList=[secondUserList tempUserList ];
end

%% �Ծ���Ϊ2���û����д���
% ȥ��
secondUserList=unique(secondUserList);
% ȥ��testUser�Լ�
secondUserList=setdiff(secondUserList,testUserID);
% ȥ��directUser
secondUserList=setdiff(secondUserList,directUserList);

%% ����Ŀ���û���ÿ��neighbor��trustֵ
directUserCount=length(directUserList);
secondUserCount=length(secondUserList);
totalSocialUserCount=directUserCount+secondUserCount;

%  ��һ�д�userID���ڶ��д�trustֵ
userSocialCircle=zeros(totalSocialUserCount,2);
userSocialCircle(1:directUserCount,1)=directUserList;
userSocialCircle(1:directUserCount,2)=1;

userSocialCircle(directUserCount+1:totalSocialUserCount,1)=secondUserList';
userSocialCircle(directUserCount+1:totalSocialUserCount,2)=0.75;


end