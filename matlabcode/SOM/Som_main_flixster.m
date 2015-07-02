clear;
tic;

% 对Item进行SOM聚类
% 空白处全部赋值为0
% versionSum=10;

heightList= [6,8,10,12,14,16,18,20];
widthList= [10,10,10,10,10,10,10,10];

for version=1:30
%  version = 1;
fprintf('current version is %d \n',version);
% for i=1:8
%     height=heightList(i);
%     width=widthList(i);
    width = 10;
    height =8;
    iter=2500;
    fprintf('current map is %d x %d \n',width,height);
    trainSetFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\trainSet%d.txt',version);   
    userRatingMatrixFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\userRatingMatrix%d.mat',version);
    weightFileName = sprintf('..\\..\\..\\data\\flixster\\commondata\\weight_%dx%d_%d.mat',width,height,version);
    coreUserFileName = sprintf('..\\..\\..\\data\\flixster\\commondata\\coreUserID%d.txt',version);
    somSaveFileName=sprintf('..\\..\\..\\data\\flixster\\somdata\\flixster_%dx%d_som%d.mat',width,height,version);
        
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
%     [neuroMatrix,bmus]=SomBatchV2_flixster(data,height,width,iter);
     [neuroMatrix,bmus]=SomBatchV2_baidu(data,height,width,iter);   % 暂时换成百度
    
%     db_index=GetDB_Index(data,neuroMatrix,bmus);
%     fprintf('the db_index is %f \n',db_index);

%     在我的推荐算法里面，要进行转置才能使用
    weight=neuroMatrix';
    itemClassIndex=bmus;
    itemCell=SplitItemByInterestCircle(itemClassIndex,size(weight,1));

    save(somSaveFileName,'uniqUserData','uniqItemData', 'weight', 'itemClassIndex');
    
%     load(somSaveFileName,'uniqUserData','uniqItemData', 'weight', 'itemClassIndex');

    [local_weight,global_weight] = CalculateWeight(userRatingMatrix, itemClassIndex, width, height);
    save(weightFileName,'local_weight','global_weight');
end


toc;