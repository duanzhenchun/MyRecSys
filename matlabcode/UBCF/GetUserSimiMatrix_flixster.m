clear
tic;
%% 得到用户之间的相似度矩阵并进行存储
%% 计算的是皮尔森相似度

% versionSum=5;
zeroThreshold = 2;

% for version=2:versionSum
    version = 1;
    fprintf('the current version is %d \n',version);
    trainSetFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\trainSet%d.txt',version);

    userRatingMatrixFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\userRatingMatrix%d.mat',version);
    saveUserSimiFileName=sprintf('..\\..\\..\\data\\flixster\\ubcfdata\\userSimiMatrix%d.mat',version);
    coreUserFileName =sprintf( '..\\..\\..\\data\\flixster\\commondata\\coreUserID%d.txt',version);

    coreUser = load(coreUserFileName);
    trainSet=load(trainSetFileName);

    userData=coreUser;
    itemData=trainSet(:,2);
    uniqUserData=unique(userData);
    uniqItemData=unique(itemData);
    userCount=length(uniqUserData);
    itemCount=length(uniqItemData);
    load(userRatingMatrixFileName,'userRatingMatrix');

    % 获得所有用户的平均打分
    userAvgRating=GetAllUserAvgRating(userRatingMatrix);

    % 采用pearson相似度计算
    userSimiMatrix=zeros(userCount,userCount);

    for i=1:userCount
%         disp(i)
        the20num=round(0.2*userCount);
        if mod(i,the20num)==0
            disp ('20%');
        end
        
        for j=i+1:userCount

            userIVector=userRatingMatrix(i,:);
            userJVector=userRatingMatrix(j,:);
            %userI 打过分的item集合
            userIitemSet=find(userIVector>0);
            %userJ 打过分的item集合
            userJitemSet=find(userJVector>0);
            %共同打过分的item集合
            commonItemSet=intersect(userIitemSet,userJitemSet);
            % 没有共同打分的item就不计算，相似度为0
            if length(commonItemSet)<=zeroThreshold
                userSimiMatrix(i,j)=0;
                userSimiMatrix(j,i)=0;
                continue
            end
            userIAvgRating=userAvgRating(i);
            userJAvgRating=userAvgRating(j);      

            % 求pearson相似度
            % for p in comset ,
            % sum[(ri,p-avgi)*(rj,p-avgj)]/(sum(ri,p-avgi)^2) ^(1/2)+(sum(rj,p-avgj)^2) ^(1/2)

            userIBias=userIVector(commonItemSet)-userIAvgRating;        
            userJBias=userJVector(commonItemSet)-userJAvgRating;    
            twoUserTotalBias=sum(userIBias.*userJBias);
            userITotalBias=sum(userIBias.*userIBias)^(1/2);
            userJTotalBias=sum(userJBias.*userJBias)^(1/2);        
            tempSimi= twoUserTotalBias/(userITotalBias*userJTotalBias); 

            %         tempSimi=tempSimi/(1+exp(-length(commonItemSet)/2));

            userSimiMatrix(i,j)= tempSimi;
            userSimiMatrix(j,i)=  userSimiMatrix(i,j);
        end
    end

    
%     
%      userSimiMatrix=zeros(userCount,userCount,'single');
%      parfor i=1:userCount
%        disp(i);
%         the20num=round(0.2*userCount);
%         if mod(i,the20num)==0
%             disp ('20%');
%         end
%        targetUserID=i;
%        urMatrix=userRatingMatrix;
%        urMatrix(urMatrix>0)=1;
%        targetUserRating=userRatingMatrix(targetUserID,:);
%        targetUserRatingMatrix=repmat(targetUserRating,userCount,1);
%        targetUserRatingMatrix(targetUserRatingMatrix>0)=1;
%        % 相加，有打分的都为1，所以共同打过分的相加为2
%        commonMatrix=urMatrix+targetUserRatingMatrix; 
%        % 不等于2的设置为0
%        commonMatrix(commonMatrix~=2)=0; 
%        % 因为是2，加了2遍，所以要除以2
%        commonMatrix=commonMatrix/2;
%        % commonItemNum  计算target用户和其他用户共同打分的个数
%        % 当个数小于一定阈值时(eg：1个)，相似度计算不准确，令相似度为0
%        commonItemNumVector=sum(commonMatrix,2);
%        noneSimiUserID=find(commonItemNumVector<=zeroThreshold);
%        
%        newurMatrix=userRatingMatrix.*commonMatrix;
%        newTargetUserRatingMatrix=repmat(targetUserRating,userCount,1);
%        newTargetUserRatingMatrix=newTargetUserRatingMatrix.*commonMatrix;
%        
%        urAvgRatingMatrix=repmat( userAvgRating ,1 ,itemCount );
%        urAvgRatingMatrix=urAvgRatingMatrix.*commonMatrix;
%        targetUserAvgRatingMatrix=userAvgRating(targetUserID) * ones( userCount , itemCount);
%        targetUserAvgRatingMatrix=targetUserAvgRatingMatrix.*commonMatrix;
%        
%        simiUserBiasMatrix=newurMatrix-urAvgRatingMatrix;
%        targetUserBiasMatrix=newTargetUserRatingMatrix-targetUserAvgRatingMatrix;
%        
%        twoUserTotalBiasVector=sum(simiUserBiasMatrix.*targetUserBiasMatrix,2);
%        simiUserTotalBiasVector=sum((simiUserBiasMatrix.*simiUserBiasMatrix),2).^(1/2);
%        targetUserTotalBiasVector=sum((targetUserBiasMatrix.*targetUserBiasMatrix),2).^(1/2);
%     
%        similarityVector=twoUserTotalBiasVector./(simiUserTotalBiasVector.*targetUserTotalBiasVector);
%       
%        % 把不相似用户相似度设置为0
%        similarityVector(noneSimiUserID)=0;
%        userSimiMatrix(i,:)=similarityVector;     
%     end
% 


    % 对角线设为0
    userSimiMatrix(logical(eye(size(userSimiMatrix))))=0;
    % 处理nan
    userSimiMatrix(isnan(userSimiMatrix))=0;

    save(saveUserSimiFileName,'userSimiMatrix');

% end

toc;
