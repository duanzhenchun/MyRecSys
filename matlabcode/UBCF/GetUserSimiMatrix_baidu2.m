clear

%% �õ��û�֮������ƶȾ��󲢽��д洢
%% �������Ƥ��ɭ���ƶ�



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


    % ��������û���ƽ�����
    userAvgRating=GetAllUserAvgRating(userRatingMatrix);

    % ����pearson���ƶȼ���
    userSimiMatrix=zeros(userCount,userCount);

    for i=1:userCount

        the20num=round(0.2*userCount);
        if mod(i,the20num)==0
            disp ('20%');
        end
        
        userIVector=userRatingMatrix(i,:);
        %userI ����ֵ�item����
        userIitemSet=find(userIVector>0);
        userIAvgRating=userAvgRating(i);
        
        parfor j=i+1:userCount
          
            userJVector=userRatingMatrix(j,:);          
            %userJ ����ֵ�item����
            userJitemSet=find(userJVector>0);
            %��ͬ����ֵ�item����
            commonItemSet=intersect(userIitemSet,userJitemSet);
            userJAvgRating=userAvgRating(j);      
            
            % û�й�ͬ��ֵ�item�Ͳ����㣬���ƶ�Ϊ0
            if length(commonItemSet)<=2
                userSimiMatrix(i,j)=0;
            else
                % ��pearson���ƶ�
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
    % �Խ�����Ϊ0
    userSimiMatrix(logical(eye(size(userSimiMatrix))))=0;
    % ����nan
    userSimiMatrix(isnan(userSimiMatrix))=0;

    save(saveUserSimiFileName,'userSimiMatrix');
    
toc;
end


