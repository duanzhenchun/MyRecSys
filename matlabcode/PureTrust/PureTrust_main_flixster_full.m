clear;
tic;
%% trust aware recsys

versionSum=10;
date='10.21';

for version = 1:30
% version = 10;
fprintf('---------------the current version is %d ----------------- \n',version);


resultFileName=sprintf('..\\..\\..\\result\\flixster\\puretrust\\flixster_puretrust_result_%d_%s.txt',version,date);
trainSetFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\trainSet%d.txt',version);
testSetFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\testSet%d.txt',version);
userRatingMatrixFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\userRatingMatrix%d.mat',version);
socialTrustFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\trust200_direct%d.txt',version);
userLevelFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\userLevel%d.txt',version);
saveRecListFileName=sprintf('..\\..\\..\\data\\flixster\\puretrustdata\\recList\\reclist%d.mat',version);
coreUserFileName =sprintf( '..\\..\\..\\data\\flixster\\commondata\\coreUserID%d.txt',version);
userSocialTrustCellFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\userSocialTrustCell_direct%d.mat',version);



trainSet = load(trainSetFileName);
testSet = load(testSetFileName);
load(userRatingMatrixFileName,'userRatingMatrix');
socialTrustData=load(socialTrustFileName);
userLevel=load(userLevelFileName);

coreUser = load(coreUserFileName);

userData=coreUser;
itemData=trainSet(:,2);
uniqUserData=unique(userData);
uniqItemData=unique(itemData);
userCount=length(uniqUserData);
itemCount=length(uniqItemData);
levelNum=length(unique(userLevel(:,2)));

testUserData=testSet(:,1);
uniqTestUserData=unique(testUserData);
testUserCount=length(uniqTestUserData);

% ȡ���û���trust�б�
load(userSocialTrustCellFileName);
% userSocialTrustCell=GetUserSocialTrust(uniqUserData,socialTrustData);
% save(userSocialTrustCellFileName,'userSocialTrustCell');

% ��������û�ƽ�����
userAvgRating=GetAllUserAvgRating(userRatingMatrix);



%% *************һЩ��������********************
likeThreshold=4;
topKList=(10:10:100);
socialNeighbourNum=50;

fprintf('current socialNeigh is %d \n', socialNeighbourNum);
recListLengthRecord=[]; % ��¼һ��ÿ���û����Ƽ��б�ĳ��ȣ��������topK

 % ��¼��ÿ���û����Ƽ��б�
allUserRecInfo = cell(testUserCount,1); 

totalPrecision = zeros(1,10);
totalRecall = zeros(1,10);
totalCount=0; %��Ϊ������precision,recall ,f1�ķ�ĸ
notCount = 0; % ���Լ�����û�����ִ��ڵ���4��

fprintf('start the iteration ...')
%% ����
parfor i=1:testUserCount
%     disp(i);
    the20num=round(0.2*testUserCount);
    if mod(i,the20num)==0
        disp ('20%');
    end
    % ���Ƽ��û�ID
    testUser=uniqTestUserData(i);
    % ��ѵ�����е�uniqUserData�� testuser��Ӧ��ID
    testUserID=find(uniqUserData==testUser);
    
    levelIdx=find(userLevel(:,1)==testUser);
    level=userLevel(levelIdx,2);
    
    %% ��ÿ���û������Ƽ�
    neighbourTrustVector=userSocialTrustCell{testUserID};
    neighbourTrustVector=neighbourTrustVector(1:socialNeighbourNum,:);

    % �ҵ���Щneighbor������item�����ɼ���unionItemSet

    neighborSet=neighbourTrustVector(:,1);
    urMatrix = userRatingMatrix(neighborSet,:)>=likeThreshold;  % relevant item
    neighBourRatingSum = sum(urMatrix,1);
    unionItemSet = find(neighBourRatingSum >0);
    
    % ȥ��testUser��trainningset���Ѿ�������item
    testUserItemSet=find(userRatingMatrix(testUserID,:)>0);
    unionItemSet=setdiff(unionItemSet,testUserItemSet);
    
    finalRecList = cell(10,1);
    if isempty(unionItemSet)
        recListLengthRecord=[recListLengthRecord; [testUser 0]];
    else
         % ��һ�д�itemID���ڶ��д���ƽ�����
        itemRankList=zeros(length(unionItemSet),2);
        itemRankList(:,1)=unionItemSet;
        % ����trust�û�������item�Ĵ��
        irMatrix=userRatingMatrix(neighborSet,unionItemSet);       
        irMatrix(irMatrix>=likeThreshold) = 1;  
        zeroIndex= irMatrix==0;
        % repmat
        trustMatrix=repmat(neighbourTrustVector(:,2),1,length(unionItemSet));
        trustMatrix(zeroIndex)=0;
        % ���
        weightedRatingMatrix=irMatrix.*trustMatrix;
        sumWeightedRating=sum(weightedRatingMatrix,1);
        itemRankList(:,2)=sumWeightedRating;  
        %����
        itemRankList=-sortrows(-itemRankList,2);
         % ��¼һ��ÿ���û����Ƽ��б�ĳ��ȣ��������topK
        recListLengthRecord=[recListLengthRecord; [testUser size(itemRankList,1)]]; 
        
        for m = 1:10
            % ��topK�����ã������Ͳ�����
            if length(itemRankList(:,1))< topKList(m)
                realTopK=length(itemRankList(:,1));
                finalRecList{m}=itemRankList(1:realTopK,1);
            else
                finalRecList{m}=itemRankList(1:topKList(m),1);
            end
        end              
       
    end
       
    %% ******************* ȡ�ò��Լ���Ŀ���û�ϲ����item�б�*******************
    % �����ִ���likeThreshold��ʾϲ��
    tempIndex=find(testSet(:,1)==testUser & testSet(:,3)>=likeThreshold);
    tempItemSet=testSet(tempIndex,2);
    
    [commonItem,IA,IB]=intersect(uniqItemData,tempItemSet);
    testUserLikedItemList=IA;
    
    if isempty(testUserLikedItemList)
        % ���Լ��û���û�����ִ���3��item���򲻿�������û����Ƽ��������Ƽ�
        notCount = notCount+1;
        continue;
    end
    
    %% ***************�����Ƽ�Ч��************************
    
    precisionList= [];
    recallList = [];
    for m = 1:10
        % ���Ƽ��б�Ͳ��Լ����û�ϲ����itemȡ��������Ϊhit����
        if isempty(finalRecList{m})
            hitList = [];
            % ���㵥���û���precision��recall
            precision = 0;
            recall = 0 ;
        else
            [hitList,iia,iib] = intersect(finalRecList{m},testUserLikedItemList);
            % ���㵥���û���precision��recall
            precision=length(hitList)/topKList(m);
            recall=length(hitList)/length(testUserLikedItemList);
        end

        if isnan(recall) || isnan(precision)
            disp('there is something wrong with the recall or the precision');
        end
        precisionList = [precisionList precision];
        recallList = [recallList recall];
     
    end
    totalPrecision = totalPrecision + precisionList;
    totalRecall = totalRecall + recallList;
    
    
    % ��¼ÿ���û������յ��Ƽ��б�
    infoCell = cell(1,5);   
    infoCell{1} = testUser;
    infoCell{2} = testUserID;
    infoCell{3} = level;
    infoCell{4} = testUserLikedItemList;
    infoCell{5} = finalRecList{10};   
    allUserRecInfo{i} = infoCell;
        
    % �ܵ����ģ�����+1�������Ϊ��ĸ
    totalCount=totalCount+1;
end

%% *******************�õ����Ľ��****************************

avgPrecision=totalPrecision/totalCount;
avgRecall=totalRecall/totalCount;
avgF1=2*avgPrecision.*avgRecall./(avgPrecision+avgRecall);

% ********** final ʵ���� ***************

for m =1 :10
    topK = topKList(m);
    finalResultFileName=sprintf('..\\..\\..\\result\\flixster\\puretrust\\final_flixster_puretrust_prf_top%d.txt',topK);
    fid = fopen(finalResultFileName,'a');
    fprintf(fid,'%f\t%f\t%f\r\n',avgPrecision(m),avgRecall(m),avgF1(m));
    fclose(fid);
end

allUserRecInfoFile = sprintf('..\\..\\..\\result\\flixster\\puretrust\\allUserRecInfo%d.mat',version);
save(allUserRecInfoFile,'allUserRecInfo');




end



toc






