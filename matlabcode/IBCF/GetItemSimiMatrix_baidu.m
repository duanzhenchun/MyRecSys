clear;

for version=1:10
fprintf('the current version is %d \n',version);
tic;

trainSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\trainSet%d.txt',version);
testSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\testSet%d.txt',version);
userRatingMatrixFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\userRatingMatrix%d.mat',version);
saveItemSimiFileName=sprintf('..\\..\\..\\data\\baidu\\ibcfdata\\itemSimiMatrix%d.mat',version);

trainSet= load(trainSetFileName);
testSet = load(testSetFileName);
load(userRatingMatrixFileName,'userRatingMatrix');

userData=testSet(:,1);
itemData=trainSet(:,2);
uniqUserData=unique(userData);
uniqItemData=unique(itemData);

itemCount=length(uniqItemData);

% 获得所有item的平均打分
itemAvgRating=GetAllItemAvgRating(userRatingMatrix);
itemSimiMatrix=zeros(itemCount,itemCount);
    
% 求相似度   
for i=1:itemCount
    
    the20num=round(0.2*itemCount);
    if mod(i,the20num)==0
        disp ('20%');
    end
    itemIVector=userRatingMatrix(:,i);
    % 给item I 打过分的 user集合
    itemIUserSet=find(itemIVector>0);      
    itemIAvgRating=itemAvgRating(i);
    
    parfor j=i+1:itemCount              
        itemJVector=userRatingMatrix(:,j);                      
        % 给item J 打过分的 user集合
        itemJUserSet=find(itemJVector>0);
        % 给两个item都打过分的user集合
        commonUserSet=intersect(itemIUserSet,itemJUserSet);
        itemJAvgRating=itemAvgRating(j);
        
       % pearson similarity
       if length(commonUserSet)<=2
           itemSimiMatrix(i,j) = 0;
       else
            itemIBias=itemIVector(commonUserSet)-itemIAvgRating;
            itemJBias=itemJVector(commonUserSet)-itemJAvgRating;
            twoItemTotalBias=sum(itemIBias.*itemJBias);
            itemITotalBias=sum(itemIBias.*itemIBias)^(1/2);
            itemJTotalBias=sum(itemJBias.*itemJBias)^(1/2);
            tempSimi=twoItemTotalBias/(itemITotalBias*itemJTotalBias);

            itemSimiMatrix(i,j)=tempSimi;
       end
%         itemSimiMatrix(j,i)=itemSimiMatrix(i,j);                                                      
    end
end

itemSimiMatrix = itemSimiMatrix + itemSimiMatrix';


% 对角线设为0
itemSimiMatrix(logical(eye(size(itemSimiMatrix))))=0;
% 处理nan
itemSimiMatrix(isnan(itemSimiMatrix))=0;

save(saveItemSimiFileName,'itemSimiMatrix');
toc;
end
