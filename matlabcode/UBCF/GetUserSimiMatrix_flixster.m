clear
tic;
%% �õ��û�֮������ƶȾ��󲢽��д洢
%% �������Ƥ��ɭ���ƶ�

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

    % ��������û���ƽ�����
    userAvgRating=GetAllUserAvgRating(userRatingMatrix);

    % ����pearson���ƶȼ���
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
            %userI ����ֵ�item����
            userIitemSet=find(userIVector>0);
            %userJ ����ֵ�item����
            userJitemSet=find(userJVector>0);
            %��ͬ����ֵ�item����
            commonItemSet=intersect(userIitemSet,userJitemSet);
            % û�й�ͬ��ֵ�item�Ͳ����㣬���ƶ�Ϊ0
            if length(commonItemSet)<=zeroThreshold
                userSimiMatrix(i,j)=0;
                userSimiMatrix(j,i)=0;
                continue
            end
            userIAvgRating=userAvgRating(i);
            userJAvgRating=userAvgRating(j);      

            % ��pearson���ƶ�
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
%        % ��ӣ��д�ֵĶ�Ϊ1�����Թ�ͬ����ֵ����Ϊ2
%        commonMatrix=urMatrix+targetUserRatingMatrix; 
%        % ������2������Ϊ0
%        commonMatrix(commonMatrix~=2)=0; 
%        % ��Ϊ��2������2�飬����Ҫ����2
%        commonMatrix=commonMatrix/2;
%        % commonItemNum  ����target�û��������û���ͬ��ֵĸ���
%        % ������С��һ����ֵʱ(eg��1��)�����ƶȼ��㲻׼ȷ�������ƶ�Ϊ0
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
%        % �Ѳ������û����ƶ�����Ϊ0
%        similarityVector(noneSimiUserID)=0;
%        userSimiMatrix(i,:)=similarityVector;     
%     end
% 


    % �Խ�����Ϊ0
    userSimiMatrix(logical(eye(size(userSimiMatrix))))=0;
    % ����nan
    userSimiMatrix(isnan(userSimiMatrix))=0;

    save(saveUserSimiFileName,'userSimiMatrix');

% end

toc;
