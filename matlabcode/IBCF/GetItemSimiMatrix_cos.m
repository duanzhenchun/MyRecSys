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

    % ��������û���ƽ�����
    userAvgRating=GetAllUserAvgRating(userRatingMatrix);
    itemSimiMatrix=zeros(itemCount,itemCount);

    % �����ƶ�   
    for i=1:itemCount
    %     disp(i);
        the20num=round(0.2*itemCount);
        if mod(i,the20num)==0
            disp ('20%');
        end
        for j=i+1:itemCount
            itemIVector=userRatingMatrix(:,i);
            itemJVector=userRatingMatrix(:,j);   
            % ��item I ����ֵ� user����
            itemIUserSet=find(itemIVector>0);           
            % ��item J ����ֵ� user����
            itemJUserSet=find(itemJVector>0);
            % ������item������ֵ�user����
            commonUserSet=intersect(itemIUserSet,itemJUserSet);

            % û�й�ͬ��ֵ�user���Ͳ����㣬���ƶ�Ϊ0
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
    %     % ��ӣ��д�ֵĶ�Ϊ1�����Թ�ͬ����ֵ����Ϊ2
    %     commonMatrix=irMatrix+targetItemRatingMatrix;
    %     % ������2������Ϊ0
    %     commonMatrix(commonMatrix~=2)=0;
    %     % ��Ϊ��2������2�飬����Ҫ����2
    %     commonMatrix=commonMatrix/2;
    %     % commonUserNum  ����targetItem������item��ͬ���û���
    %     % ������С��һ����ֵʱ(eg��1��)�����ƶȼ��㲻׼ȷ�������ƶ�Ϊ-1
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
    %     % �Ѳ�����item ���ƶ�����Ϊ0
    %     similarityVector(noneSimiItemID)=0;
    %     itemSimiMatrix(i,:)=similarityVector;
    %     
    % end



    % �Խ�����Ϊ0
    itemSimiMatrix(logical(eye(size(itemSimiMatrix))))=0;
    % ����nan
    itemSimiMatrix(isnan(itemSimiMatrix))=0;

    save(saveItemSimiFileName,'itemSimiMatrix');

end

toc;