clear;
tic;

% 对Item进行SOM聚类
% 空白处全部赋值为0
versionSum=30;

% heightList= [2,4,8,6,8,10,12];
% widthList= [5,5,5,10,10,10,10];
% version = 1;
for version=12:30
    fprintf('current version is %d \n',version);

    width = 5;
    height = 8;
    iter=2500;
    fprintf('current map is %d x %d \n',width,height);
    trainSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\trainSet%d.txt',version); 
    userRatingMatrixFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\userRatingMatrix%d.mat',version);
    weightFileName = sprintf('..\\..\\..\\data\\baidu\\commondata\\weight_%dx%d_%d.mat',width,height,version);
    coreUserFileName = sprintf('..\\..\\..\\data\\baidu\\commondata\\coreUserID.txt');
    somSaveFileName=sprintf('..\\..\\..\\data\\baidu\\somdata\\baidu_%dx%d_som%d.mat',width,height,version);
    
    load(userRatingMatrixFileName,'userRatingMatrix');
    trainSet= load(trainSetFileName);
    coreUser = load(coreUserFileName);
    
    userData=coreUser;  
    itemData=trainSet(:,2);
    ratingData=trainSet(:,3);
    uniqUserData=unique(userData);
    uniqItemData=unique(itemData);
    userCount=length(uniqUserData);
    itemCount=length(uniqItemData);

    % ******************一些设置********************************************
    userRatingMatrix = full(userRatingMatrix);
    data=userRatingMatrix;
    
    % ******************* 训练 ********************************
    [neuroMatrix,bmus]=SomBatchV2_baidu(data,height,width,iter);
    
%     db_index=GetDB_Index(data,neuroMatrix,bmus);
%     fprintf('the db_index is %f \n',db_index);

    % 在我的推荐算法里面，要进行转置才能使用
    weight=neuroMatrix';
    itemClassIndex=bmus;
    itemCell=SplitItemByInterestCircle(itemClassIndex,size(weight,1));

    save(somSaveFileName,'uniqUserData','uniqItemData','weight', 'itemClassIndex');
    
    [local_weight,global_weight] = CalculateWeight(userRatingMatrix, itemClassIndex, width, height);
    save(weightFileName,'local_weight','global_weight');
end
% end
toc;