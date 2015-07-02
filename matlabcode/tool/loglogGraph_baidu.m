% % ����loglogͼ
% ratingSetFileName='..\..\..\data\baidu\commondata\finalRating.txt';
% ratingSet=load(ratingSetFileName);
% 
% userData=ratingSet(:,1);
% itemData=ratingSet(:,2);
% uniqUserData=unique(userData);
% uniqItemData=unique(itemData);
% userCount=length(uniqUserData);
% itemCount=length(uniqItemData);
% 
% 
% %% ��ȫ������Ϊ0�����зֵĵط�������ʣ�����0����
% userRatingMatrix=zeros(userCount,itemCount);
% totalCount=size(ratingSet,1);
% for m=1:totalCount
%     trainCase=ratingSet(m,:);  %ѵ�����е�ÿ����¼
%     user=trainCase(1);
%     item=trainCase(2);
%     % �����ݼ��е�user��item���ַ���ӳ��Ϊ������
%     % ������uniqUserData��uniqItemData�е�λ����Ϊ����
%     userID=find(uniqUserData==user);
%     itemID=find(uniqItemData==item);
%     rating=trainCase(3);
%     userRatingMatrix(userID,itemID)=rating;
% end
% 
% save('userRatingMatrix-baidu.mat','userRatingMatrix');



load('userRatingMatrix-baidu.mat','userRatingMatrix');
userCount=size(userRatingMatrix,1);
itemCount=size(userRatingMatrix,2);

userRatingCount=zeros(userCount,1);

for i=1:userCount
    userRatingVector=userRatingMatrix(i,:);
    realRating=find(userRatingVector>0);
    ratingCount=length(realRating);
    userRatingCount(i)=ratingCount;   
end

startX=min(userRatingCount);
endX=max(userRatingCount);
x=startX:1:endX;
y=zeros(1,length(x));
for m=1:length(x)
   tempx=x(m);
   idx=find(userRatingCount==tempx);
   y(m)=length(idx);
end

logx=log(x);
logy=log(y);

loglog(x,y,'b.');


grid on;



% 
% % scatter(logx,logy,4,'fill');
% % xtick=[0 1 2 3 4 5 6 ];
% % ytick=[0 1 2 3 4 5 6 ];
% % xticklabel=[1 10 100 1000 10000 100000 1000000];
% % yticklabel=[1 10 100 1000 10000 100000 1000000];
% % set(gca,'xtick',xtick,'ytick',ytick);
% % 
% % % loglog(x,y);
% % % set(gca,'xtick',logx,'XTicklabel',x,'yTick',logy,'yTicklabel',y) ;
% % grid on;
% % 
% % 


