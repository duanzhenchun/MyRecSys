clear;
tic;

% 对Item进行SOM聚类
% 空白处全部赋值为0
versionSum=5;

heightList= [2,4,6,8,10,10,10,10,10,10];
widthList= [5,5,5,5,5,6,7,8,9,10];

version = 1;
for k = 1:10
    fprintf('current version is %d \n',version);
    width = widthList(k);
    height = heightList(k);
%     width = 5;
%     height = 4;
    iter=2000;
    fprintf('current map is %d x %d \n',width,height);
    trainSetFileName = sprintf('..\\..\\..\\data\\movielens\\commondata\\trainSet%d.txt',version); 
    userRatingMatrixFileName = sprintf('..\\..\\..\\data\\movielens\\commondata\\userRatingMatrix%d.mat',version);
    weightFileName = sprintf('..\\..\\..\\data\\movielens\\commondata\\weight_%dx%d_%d.mat',width,height,version);
    somSaveFileName = sprintf('..\\..\\..\\data\\movielens\\somdata\\movielens_%dx%d_som%d.mat',width,height,version);
    
    load(userRatingMatrixFileName,'userRatingMatrix');
    trainSet= load(trainSetFileName);

    
    userData=trainSet(:,1);  
    itemData=trainSet(:,2);
    ratingData=trainSet(:,3);
    uniqUserData=unique(userData);
    uniqItemData=unique(itemData);
    userCount=length(uniqUserData);
    itemCount=length(uniqItemData);

    % ******************一些设置********************************************
    userRatingMatrix = full(userRatingMatrix);
    data = userRatingMatrix;
    
    % ******************* 训练 ********************************
    [neuroMatrix,bmus]=SomBatchV2_baidu(data,height,width,iter);
    
%     db_index=GetDB_Index(data,neuroMatrix,bmus);
%     fprintf('the db_index is %f \n',db_index);

    % 在我的推荐算法里面，要进行转置才能使用
    weight=neuroMatrix';
    itemClassIndex=bmus;

    save(somSaveFileName,'uniqUserData','uniqItemData','weight', 'itemClassIndex');
    
    [local_weight,global_weight] = CalculateWeight(userRatingMatrix, itemClassIndex, width, height);
    save(weightFileName,'local_weight','global_weight');

end
% end
toc;