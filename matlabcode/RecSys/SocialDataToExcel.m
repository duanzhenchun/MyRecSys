TrainSet=load('F:\BaiduProject\mydata1\mapUserSocialForMatlab.txt');
UserSocialMatrix=zeros(566,566); %定义用户社交关系矩阵，全部先填为0
TotalCount=size(TrainSet,1);

for m=1:TotalCount
    TrainCase=TrainSet(m,:);
    user1=TrainCase(1);   %目标用户
    user2=TrainCase(2);   %目标用户关注的用户
    UserSocialMatrix(user1,user2)=1;
end

%  xlswrite('F:\test.xlsx',UserSocialMatrix);
csvwrite('f:\test.csv',UserSocialMatrix);