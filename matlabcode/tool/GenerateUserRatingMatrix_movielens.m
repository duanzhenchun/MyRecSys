clear;
tic

versionSum = 5;
for version=1:versionSum

    fprintf('current version is %d \n',version);
    trainSetFileName=sprintf('..\\..\\..\\data\\movielens\\commondata\\trainSet%d.txt',version);
    saveFileName=sprintf('..\\..\\..\\data\\movielens\\commondata\\userRatingMatrix%d.mat',version);

    trainSet=load(trainSetFileName);


    userData=trainSet(:,1);
    itemData=trainSet(:,2);
    uniqUserData=unique(userData);
    uniqItemData=unique(itemData);
    userCount=length(uniqUserData);
    itemCount=length(uniqItemData);

    %% 先全部都赋为0，当有分的地方填满后，剩余的以0代替
    userRatingMatrix=zeros(userCount,itemCount);
    totalCount=size(trainSet,1);
    for m=1:totalCount
        trainCase=trainSet(m,:);  %训练集中的每条记录
        user=trainCase(1);
        item=trainCase(2);
        % 将数据集中的user和item的字符串映射为序数，
        % 以其在uniqUserData和uniqItemData中的位置作为序数
        userID=find(uniqUserData==user);
        itemID=find(uniqItemData==item);
        rating=trainCase(3);
        userRatingMatrix(userID,itemID)=rating;
    end
    userRatingMatrix = sparse(userRatingMatrix);
    save(saveFileName,'userRatingMatrix');

    fprintf('finished... \r\n');
end

toc;