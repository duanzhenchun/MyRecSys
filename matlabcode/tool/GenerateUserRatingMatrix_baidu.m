clear;
tic

versionSum=30;
for version=1:versionSum

    fprintf('current version is %d \n',version);
    trainSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\trainSet%d.txt',version);
    testSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\testSet%d.txt',version);
    coreUserFileName = sprintf('..\\..\\..\\data\\baidu\\commondata\\coreUserID.txt');
    saveFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\userRatingMatrix%d.mat',version);

    trainSet=load(trainSetFileName);
    testSet=load(testSetFileName);
    coreUser = load(coreUserFileName);
       
    userData=coreUser;
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