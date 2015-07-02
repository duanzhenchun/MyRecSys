clear;
tic;

versionSum=5;

for version=1:versionSum
    
    fprintf('the current version is %d \n',version);
    trainSetFileName=sprintf('..\\..\\..\\data\\movielens\\commondata\\trainSet%d.txt',version);
    userRatingMatrixFileName=sprintf('..\\..\\..\\data\\movielens\\commondata\\userRatingMatrix%d.mat',version);
    saveItemSimiFileName=sprintf('..\\..\\..\\data\\movielens\\ibcfdata\\itemSimiMatrix_cos%d.mat',version);

    trainSet=load(trainSetFileName);
    load(userRatingMatrixFileName,'userRatingMatrix');

    userData=trainSet(:,1);
    itemData=trainSet(:,2);
    uniqUserData=unique(userData);
    uniqItemData=unique(itemData);
    userCount=length(uniqUserData);
    itemCount=length(uniqItemData);

    % 获得所有用户的平均打分
    userAvgRating=GetAllUserAvgRating(userRatingMatrix);
    itemSimiMatrix=zeros(itemCount,itemCount);

    % 求相似度   
    for i=1:itemCount
    %     disp(i);
        the20num=round(0.2*itemCount);
        if mod(i,the20num)==0
            disp ('20%');
        end
        for j=i+1:itemCount
            itemIVector=userRatingMatrix(:,i);
            itemJVector=userRatingMatrix(:,j);   
            % 给item I 打过分的 user集合
            itemIUserSet=find(itemIVector>0);           
            % 给item J 打过分的 user集合
            itemJUserSet=find(itemJVector>0);
            % 给两个item都打过分的user集合
            commonUserSet=intersect(itemIUserSet,itemJUserSet);

            % 没有共同打分的user，就不计算，相似度为0
            if length(commonUserSet)<=1
                itemSimiMatrix(i,j)=0;
                itemSimiMatrix(j,i)=0;
                continue
            end

              % adjusted cosine similarity
            % for u in commmon userset
                %sum[(ru,i-avgu)(ru,j-avgu)]/([ sum(ru,i-avgu)^2} *[sum(ru,j-avgu)^2])^(1/2)     

            commonUserAvgRating=userAvgRating(commonUserSet);
            itemIBias=itemIVector(commonUserSet)-commonUserAvgRating;
            itemJBias=itemJVector(commonUserSet)-commonUserAvgRating;
            twoItemTotalBias=sum(itemIBias.*itemJBias);
            itemITotalBias=sum(itemIBias.*itemIBias)^(1/2);
            itemJTotalBias=sum(itemJBias.*itemJBias)^(1/2);
            tempSimi=twoItemTotalBias/(itemITotalBias*itemJTotalBias);

    %             tempSimi=length(commonUserSet)/length(union(itemIUserSet,itemJUserSet));

            %         tempSimi=tempSimi/(1+exp(-length(commonUserSet)/2));
            itemSimiMatrix(i,j)=tempSimi;
            itemSimiMatrix(j,i)=itemSimiMatrix(i,j);                                                      
        end
    end

    % % adjusted cosine similarity
    % parfor i=1:itemCount
    % 
    % %     disp(i);
    %     the20num=round(0.2*itemCount);
    %     if mod(i,the20num)==0
    %         disp ('20%');
    %     end
    %     targetItemID=i;
    %     irMatrix=userRatingMatrix;
    %     irMatrix(irMatrix>0)=1;
    %     targetItemRating=userRatingMatrix(:,targetItemID);
    %     targetItemRatingMatrix=repmat(targetItemRating,1,itemCount);
    %     targetItemRatingMatrix(targetItemRatingMatrix>0)=1;
    %     % 相加，有打分的都为1，所以共同打过分的相加为2
    %     commonMatrix=irMatrix+targetItemRatingMatrix;
    %     % 不等于2的设置为0
    %     commonMatrix(commonMatrix~=2)=0;
    %     % 因为是2，加了2遍，所以要除以2
    %     commonMatrix=commonMatrix/2;
    %     % commonUserNum  计算targetItem和其他item共同的用户数
    %     % 当个数小于一定阈值时(eg：1个)，相似度计算不准确，令相似度为-1
    %     commonUserNumVector=sum(commonMatrix,1);
    %     noneSimiItemID=find(commonUserNumVector<=1);
    %     
    %     newirMatrix=userRatingMatrix.*commonMatrix;
    %     newTargetItemRatingMatrix=repmat(targetItemRating,1,itemCount);
    %     newTargetItemRatingMatrix=newTargetItemRatingMatrix.*commonMatrix;
    %     
    %     userAvgMatrix=repmat(userAvgRating,1,itemCount);
    %     userAvgMatrix=userAvgMatrix.*commonMatrix;
    %     
    %     simiItemBiasMatrix=newirMatrix-userAvgMatrix;
    %     targetItemBiasMatrix=newTargetItemRatingMatrix-userAvgMatrix;
    %     
    %     twoItemTotalBiasVector=sum(simiItemBiasMatrix.*targetItemBiasMatrix,1);
    %     simiItemTotalBiasVector=sum(simiItemBiasMatrix.*simiItemBiasMatrix,1).^(1/2);
    %     targetItemTotalBiasVector=sum(targetItemBiasMatrix.*targetItemBiasMatrix,1).^(1/2);
    %     
    %     similarityVector=twoItemTotalBiasVector./(simiItemTotalBiasVector.*targetItemTotalBiasVector);
    %     % 把不相似item 相似度设置为0
    %     similarityVector(noneSimiItemID)=0;
    %     itemSimiMatrix(i,:)=similarityVector;
    %     
    % end



    % 对角线设为0
    itemSimiMatrix(logical(eye(size(itemSimiMatrix))))=0;
    % 处理nan
    itemSimiMatrix(isnan(itemSimiMatrix))=0;

    save(saveItemSimiFileName,'itemSimiMatrix');

end

toc;