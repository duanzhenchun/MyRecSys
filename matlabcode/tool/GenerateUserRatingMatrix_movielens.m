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

    %% ��ȫ������Ϊ0�����зֵĵط�������ʣ�����0����
    userRatingMatrix=zeros(userCount,itemCount);
    totalCount=size(trainSet,1);
    for m=1:totalCount
        trainCase=trainSet(m,:);  %ѵ�����е�ÿ����¼
        user=trainCase(1);
        item=trainCase(2);
        % �����ݼ��е�user��item���ַ���ӳ��Ϊ������
        % ������uniqUserData��uniqItemData�е�λ����Ϊ����
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