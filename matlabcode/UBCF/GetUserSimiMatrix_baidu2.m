clear

%% 得到用户之间的相似度矩阵并进行存储
%% 计算的是皮尔森相似度



for version=4:6
    
    fprintf('the current version is %d \n',version);
    tic;
   
    trainSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\trainSet%d.txt',version);
    testSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\testSet%d.txt',version);
    userRatingMatrixFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\userRatingMatrix%d.mat',version);
    saveUserSimiFileName=sprintf('..\\..\\..\\data\\baidu\\ubcfdata\\userSimiMatrix%d.mat',version);
    
    trainSet= load(trainSetFileName);
    testSet = load(testSetFileName);
    load(userRatingMatrixFileName,'userRatingMatrix');

    
    userData=testSet(:,1);
    itemData=trainSet(:,2);
    uniqUserData=unique(userData);
    uniqItemData=unique(itemData);
    userCount=length(uniqUserData);
    itemCount=length(uniqItemData);


    % 获得所有用户的平均打分
    userAvgRating=GetAllUserAvgRating(userRatingMatrix);

    % 采用pearson相似度计算
    userSimiMatrix=zeros(userCount,userCount);

    for i=1:userCount

        the20num=round(0.2*userCount);
        if mod(i,the20num)==0
            disp ('20%');
        end
        
        userIVector=userRatingMatrix(i,:);
        %userI 打过分的item集合
        userIitemSet=find(userIVector>0);
        userIAvgRating=userAvgRating(i);
        
        parfor j=i+1:userCount
          
            userJVector=userRatingMatrix(j,:);          
            %userJ 打过分的item集合
            userJitemSet=find(userJVector>0);
            %共同打过分的item集合
            commonItemSet=intersect(userIitemSet,userJitemSet);
            userJAvgRating=userAvgRating(j);      
            
            % 没有共同打分的item就不计算，相似度为0
            if length(commonItemSet)<=2
                userSimiMatrix(i,j)=0;
            else
                % 求pearson相似度
                % for p in comset ,
                % sum[(ri,p-avgi)*(rj,p-avgj)]/(sum(ri,p-avgi)^2) ^(1/2)+(sum(rj,p-avgj)^2) ^(1/2)

                userIBias = userIVector(commonItemSet)-userIAvgRating;        
                userJBias = userJVector(commonItemSet)-userJAvgRating;    
                twoUserTotalBias=sum(userIBias.*userJBias);
                userITotalBias=sum(userIBias.*userIBias)^(1/2);
                userJTotalBias=sum(userJBias.*userJBias)^(1/2);        
                tempSimi= twoUserTotalBias/(userITotalBias*userJTotalBias); 

                userSimiMatrix(i,j)= tempSimi;
            end
          
        end
    end
    userSimiMatrix = userSimiMatrix + userSimiMatrix';
    % 对角线设为0
    userSimiMatrix(logical(eye(size(userSimiMatrix))))=0;
    % 处理nan
    userSimiMatrix(isnan(userSimiMatrix))=0;

    save(saveUserSimiFileName,'userSimiMatrix');
    
toc;
end


