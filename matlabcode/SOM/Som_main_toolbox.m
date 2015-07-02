clear;
tic;

% 对Item进行SOM聚类
% 空白处全部赋值为0
version=2;
height=10;
width=10;
trainSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\trainSet%d.txt',version);
somSaveFileName=sprintf('..\\..\\..\\data\\baidu\\somdata\\baidu_tool_%dx%d_som%d.mat',width,height,version);
userRatingMatrixFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\userRatingMatrix%d.mat',version);

load(userRatingMatrixFileName,'userRatingMatrix');
iter=2000;
trainSet= load(trainSetFileName);
userData=trainSet(:,1);
itemData=trainSet(:,2);
ratingData=trainSet(:,3);
uniqUserData=unique(userData);
uniqItemData=unique(itemData);
userCount=length(uniqUserData);
itemCount=length(uniqItemData);

% ************************ tool box ******************************************** 
radius_init=floor(min(height,width)/2);
boxData=userRatingMatrix'/5;    % 要求是 dlen x dim
sMap = som_randinit(boxData,'msize', [width height],'lattice','rect');
[sMap,sTrain]=som_batchtrain(sMap,boxData,'trainlen',iter,'radius_ini',radius_init,'radius_fin',1,'tracking',1,...
    'neigh','gaussian');
boxNeuroMatrix=sMap.codebook;   % len x dim 
dataNum=size(boxData,1);
boxInputClass=zeros(dataNum,1);
for i=1:dataNum
    inputData=boxData(i,:);
    bestMatchID=GetBestMatch(inputData',boxNeuroMatrix');  % 里面都是以列计算的
    boxInputClass(i)=bestMatchID;
end
db_index=GetDB_Index(boxData',boxNeuroMatrix',boxInputClass);
fprintf('the db_index is %f \n',db_index)
boxItemCell=SplitItemByInterestCircle(boxInputClass,size(boxNeuroMatrix,1));

weight=boxNeuroMatrix;
itemClassIndex=boxInputClass;
save(somSaveFileName,'uniqUserData','uniqItemData', 'userRatingMatrix','weight', 'itemClassIndex')
toc;