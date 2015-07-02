clear;
tic;

version=1;   % 第几套数据集
width=5;height=5;
ratingSomFileName=sprintf('..\\..\\..\\data\\baidu\\somdata\\baidu_%dx%d_som%d.mat',width,height,version); 
userRatingMatrixFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\userRatingMatrix%d.mat',version);
% weightFileName = sprintf('..\\..\\..\\data\\baidu\\commondata\\weight_%dx%d.mat',width,height);
load(ratingSomFileName, 'uniqUserData', 'uniqItemData', 'itemClassIndex');
load(userRatingMatrixFileName);
% load(weightFileName);

userCount=length(uniqUserData);
itemCount=length(uniqItemData);
interestCount=size(weight,1);
weightHitCell=cell(userCount,1);

for i=1: userCount
    tempWeight=weight(:,i);
    itemSet=find(userRatingMatrix(i,:)>0);
    itrRecord=zeros(interestCount,3);
    itrRecord(:,1)=(1:interestCount);
    for m=1:length(itemSet)
        itemID=itemSet(m);
        tempItr=itemClassIndex(itemID);
        itrRecord(tempItr,2)=itrRecord(tempItr,2)+1;
        itrRecord(tempItr,3)=itrRecord(tempItr,3)+userRatingMatrix(i,itemID);
    end
    itrRecord(:,3)= itrRecord(:,3)./itrRecord(:,2);
    
    weightHitMatrix=zeros(interestCount,3);
    weightHitMatrix(:,1)=tempWeight;
    weightHitMatrix(:,2)=itrRecord(:,2);
    weightHitMatrix(:,3)=itrRecord(:,3);
    weightHitMatrix(isnan(weightHitMatrix))=0;
    weightHitCell{i}=weightHitMatrix;    
   
end





toc;