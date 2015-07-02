clear
tic;
%% 得到用户之间的相似度矩阵并进行存储
%% 计算的是皮尔森相似度

% versionSum=5;
% zeroThreshold = 2;

for version=2:10
%     version = 1;
    fprintf('the current version is %d \n',version);
    trainSetFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\trainSet%d.txt',version);

    featureMatrixFileName=sprintf('..\\..\\..\\data\\flixster\\mfdata_topN\\MF_fac20_rm-1_wm0.200_lamb0.100_ver%d.mat',version);
    saveItemSimiFileName=sprintf('..\\..\\..\\data\\flixster\\ibcfdata\\MF_itemSimiMatrix%d.mat',version);
    coreUserFileName = sprintf('..\\..\\..\\data\\flixster\\commondata\\coreUserID%d.txt',version);

    
    coreUser = load(coreUserFileName);
    trainSet=load(trainSetFileName);

    userData=coreUser;
    itemData=trainSet(:,2);
    uniqUserData=unique(userData);
    uniqItemData=unique(itemData);
    userCount=length(uniqUserData);
    itemCount=length(uniqItemData);
    load(featureMatrixFileName,'P');   
    itemFeatureMatrix = P;
    


    % 采用pearson相似度计算
    itemSimiMatrix=zeros(itemCount,itemCount);

    
    for i=1:itemCount
%         disp(i)
        the20num=round(0.2*itemCount);
        if mod(i,the20num)==0
            disp ('20%');
        end
        
        itemIVector=itemFeatureMatrix(i,:);
        itemIAvgRating=mean(itemIVector);
        itemIBias = itemIVector-itemIAvgRating;      
        itemITotalBias=sum(itemIBias.*itemIBias)^(1/2);
        for j=i+1:itemCount

            
            itemJVector=itemFeatureMatrix(j,:);                      
            itemJAvgRating=mean(itemJVector);      

            % 求pearson相似度
            % for p in comset ,
            % sum[(ri,p-avgi)*(rj,p-avgj)]/(sum(ri,p-avgi)^2) ^(1/2)+(sum(rj,p-avgj)^2) ^(1/2)

           
            itemJBias = itemJVector-itemJAvgRating;    
            itemJTotalBias=sum(itemJBias.*itemJBias)^(1/2);   
            twoItemTotalBias=sum(itemIBias.*itemJBias);                        
            tempSimi= twoItemTotalBias/(itemITotalBias*itemJTotalBias); 

            %         tempSimi=tempSimi/(1+exp(-length(commonItemSet)/2));

            itemSimiMatrix(i,j)= tempSimi;
            itemSimiMatrix(j,i)= tempSimi;
        end
    end

    

    % 对角线设为0
    itemSimiMatrix(logical(eye(size(itemSimiMatrix))))=0;
    % 处理nan
    itemSimiMatrix(isnan(itemSimiMatrix))=0;
    
    save(saveItemSimiFileName,'itemSimiMatrix','-v7.3');
%     clear;
end

toc;
