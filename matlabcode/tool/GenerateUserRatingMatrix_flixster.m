clear;
tic

versionSum=10;
for version=1:30
%     version =2 ;
    fprintf('current version is %d \n',version);
    trainSetFileName = sprintf('..\\..\\..\\data\\flixster\\commondata\\trainSet%d.txt',version);
    testSetFileName = sprintf('..\\..\\..\\data\\flixster\\commondata\\testSet%d.txt',version);
    coreUserFileName = sprintf('..\\..\\..\\data\\flixster\\commondata\\coreUserID%d.txt',version);   
    saveFileName = sprintf('..\\..\\..\\data\\flixster\\commondata\\userRatingMatrix%d.mat',version);

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
    totalCount=size(trainSet,1);
    uList = zeros(totalCount, 1);
    iList = zeros(totalCount, 1);
    rList = zeros(totalCount, 1);
   
    for m=1:totalCount
        trainCase=trainSet(m,:);  %ѵ�����е�ÿ����¼
        user=trainCase(1);
        item=trainCase(2);
        % �����ݼ��е�user��item���ַ���ӳ��Ϊ������
        % ������uniqUserData��uniqItemData�е�λ����Ϊ����
        uid = find(uniqUserData==user);
        iid = find(uniqItemData==item);
        rating = trainCase(3);
        uList(m) = uid;
        iList(m) = iid;
        rList(m) = rating;
    end  
    userRatingMatrix=sparse(uList,iList,rList,userCount,itemCount);

    
    save(saveFileName,'userRatingMatrix');

    fprintf('finished... \r\n');
end

toc;