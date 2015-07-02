%��ȫ��Ϣ
clear;
TrainSet= load('f:\BaiduProject\mydata1\set\TrainSet5.txt');
UserRatingMatrix=zeros(566,7695);  %ȫ����ֵΪ0

TotalCount=size(TrainSet,1);
for m=1:TotalCount
    TrainCase=TrainSet(m,:);  %ѵ�����е�ÿ����¼
    user=TrainCase(1);
    item=TrainCase(2);
    rating=TrainCase(3);
    UserRatingMatrix(user,item)=rating;
end
% ����ƽ���ֲ���
itemAvgRating=zeros(1,7695);
for k=1:7695
    tempSum=sum(UserRatingMatrix(:,k));
    tempCount=length(find(UserRatingMatrix(:,k)>0));
    meanRating=tempSum/tempCount;
    itemAvgRating(k)=meanRating;
end

save ratingSomByZero5 itemAvgRating -append;

clear;
load  ratingSomByZero5 net UserRatingMatrix;

% ���·���
itemClass=sim(net,UserRatingMatrix);
itemClassIndex=vec2ind(itemClass); %1x7000��� ����

weight=net.IW{1,1};

save  ratingSomByZero5 itemClass itemClassIndex weight -append