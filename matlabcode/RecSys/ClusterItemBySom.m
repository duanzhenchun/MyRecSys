clear;
clc;
tic;
% ��Item����SOM����
% �հ״�ȫ����ֵΪ0
trainSet= load('..\..\..\data\baidu\data1\trainSet1.txt');
userData=trainSet(:,1);
itemData=trainSet(:,2);
ratingData=trainSet(:,3);
uniqUserData=unique(userData);
uniqItemData=unique(itemData);
userCount=length(uniqUserData);
itemCount=length(uniqItemData);

% ��ӡuser  item����
disp(userCount);
disp(itemCount);
disp(length(ratingData));

% ��ȫ������Ϊ0�����зֵĵط�������ʣ�����0����
userRatingMatrix=zeros(userCount,itemCount);  
totalCount=size(trainSet,1);
for m=1:totalCount
    trainCase=trainSet(m,:);  %ѵ�����е�ÿ����¼
    user=trainCase(1);
    item=trainCase(2);
    % �����ݼ��е�user��item���ַ���ӳ��Ϊ������
    % ������uniqUserData��uniqItemData�е�λ����Ϊ����
    userID=find(uniqUserData==user);
    itemID=find(uniqItemData==item);
    rating=trainCase(3);
    userRatingMatrix(userID,itemID)=rating;
end

% % ���հ״�����ÿ���û���ƽ�����
% for k=1:566
%     tempSum=sum(UserRatingMatrix(k,:));
%     tempCount=length(find(UserRatingMatrix(k,:)>0));
%     meanRatingByUser=tempSum/tempCount;
%     [x,y]=find(UserRatingMatrix(k,:)==0);
%     UserRatingMatrix(k,y)=meanRatingByUser; % ����x�У����ǵ�k��
% end

addpath '..\..\..\code\matlabcode\SOM'
% ���ݹ�һ��
inputdata=userRatingMatrix/5;
height=5;
width=5;
iter=500;
[weight,itemClassIndex]=SomBatch(inputdata,height,width,iter);

% ԭʼweight ά��Ϊ User���� x neuro����������Ҫת��
% **********�ǳ���Ҫ*********************
weight=weight';
% ***************************************


% weight    ά��Ϊ neuro���� x  User ����
% itemClassIndex    ά��Ϊ itemNum x  1 



% % �����־�����som�ľ���
% net=newsom(userRatingMatrix,[5 5]);
% net.trainParam.epochs = 200;
% net.layers{1}.distanceFcn='dist';
% net=train(net,userRatingMatrix);
% plotsomhits(net,userRatingMatrix);
% weight=net.IW{1,1};
% weight=weight/5;
% 
% % ���·���
% itemClass=sim(net,userRatingMatrix);
% % ���ÿ��item���䵽�ľ���ı��
% itemClassIndex=vec2ind(itemClass); %1x7000��� ����

toc;
save ratingSomOutcome3.mat
