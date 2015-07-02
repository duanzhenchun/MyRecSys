
width = 10;
height = 10;

for version=1:1
    sprintf('current version is %d \n',version)
    userRatingMatrixFileName = sprintf('..\\..\\..\\data\\movielens\\commondata\\userRatingMatrix%d.mat',version);
    somSaveFileName=sprintf('..\\..\\..\\data\\movielens\\somdata\\movielens_%dx%d_som%d.mat',width,height,version);
    
    weightFileName = sprintf('..\\..\\..\\data\\movielens\\commondata\\simple_weight_%dx%d_%d.mat',width,height,version);
    
    load(userRatingMatrixFileName,'userRatingMatrix');
    userRatingMatrix = full(userRatingMatrix);
    load(somSaveFileName, 'itemClassIndex');
 
    [local_weight,global_weight] = CalculateWeight_huiyi(userRatingMatrix, itemClassIndex, width, height);
    save(weightFileName,'local_weight','global_weight');
 
end