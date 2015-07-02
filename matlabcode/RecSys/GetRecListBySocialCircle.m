% �����û����罻Ȧ�������Ƽ�
clear;
clc;
load ratingSomOutcome1.mat ...
    uniqUserData uniqItemData ...
    userRatingMatrix weight itemClassIndex

% �����ڽӾ���
userCount=length(uniqUserData);
socialMatrix=zeros(userCount,userCount);

testSet= load('..\..\..\data\baidu\data1\testSet1.txt');
testUserData=testSet(:,1);
uniqTestUserData=unique(testUserData);
testUserCount=length(uniqTestUserData);



% �����罻��Ϣ
socialData=load('..\..\..\data\baidu\data1\finalSocial.txt');
for m=1:size(socialData,1)
    socialLink=socialData(m,:);
    sourceUser=socialLink(1);
    targetUser=socialLink(2);
    sourceUserID=find(uniqUserData==sourceUser);
    targetUserID=find(uniqUserData==targetUser);
    %�ԳƵ�
    socialMatrix(sourceUserID,targetUserID)=1;
    socialMatrix(targetUserID,sourceUserID)=1;
end


% for i=1:testUserCount
for i=4
    testUser=uniqTestUserData(i);
    testUserID=find(uniqUserData==testUser);   
    userSocialCircle=FindUserSocialCircle(testUserID,socialMatrix);
    
    
    
    % getInterest by social user
    socialInterest=zeros(size(weight,1),3);
    socialInterest(:,1)=(1:size(weight,1));
    
    for j=1:size(userSocialCircle,1)
        tempSocialUserID=userSocialCircle(j,1);
        trust=userSocialCircle(j,2);
        tempWeight=weight(:,tempSocialUserID);
        tempIntersetList=find(tempWeight>0);
        for k=1:length(tempIntersetList)
            itrNo=tempIntersetList(k);
            itrWeight=tempWeight(k);
            socialInterest(itrNo,2)=socialInterest(itrNo,2)+itrWeight*trust;
            socialInterest(itrNo,3)=socialInterest(itrNo,3)+trust;
        end      
    end
%     ȥ�������У�û����
    socialInterest(:,3)=[];
    % ��Ȩƽ��
    socialInterest(:,2)=socialInterest(:,2)./socialInterest(:,3);
    % ����,����
    socialInterest=-sortrows(-socialInterest,2);

    
end




