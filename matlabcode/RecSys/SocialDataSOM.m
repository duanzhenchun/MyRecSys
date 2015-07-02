TrainSet=load('F:\BaiduProject\mydata1\mapUserSocialForMatlab.txt');
UserSocialMatrix=zeros(566,566); %�����û��罻��ϵ����ȫ������Ϊ0
TotalCount=size(TrainSet,1);

for m=1:TotalCount
    TrainCase=TrainSet(m,:);
    user1=TrainCase(1);   %Ŀ���û�
    user2=TrainCase(2);   %Ŀ���û���ע���û�
    UserSocialMatrix(user1,user2)=1;
end


%��ת�ã������ʾ����ÿ���û���˵������Щ�û�������

net=newsom(UserSocialMatrix,[2 3],'hextop','linkdist',300,3);
net=train(net,UserSocialMatrix);
plotsompos(net,UserSocialMatrix);