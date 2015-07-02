clear;
tic;

%% ���һ�� ������


%% **************���ļ�����ʹ洢��Ŀ¼���������趨*********************************


alphaList = (0:0.1:1);
for k =1:length(alphaList)
alpha = alphaList(k);
fprintf('current alpha  is %f \n',alpha)
for version=1:30
% version=1;   % �ڼ������ݼ�
fprintf('---------------the current version is %d ----------------- \n',version);

width=5;
height=8;


ratingSomFileName=sprintf('..\\..\\..\\data\\baidu\\somdata\\baidu_%dx%d_som%d.mat',width,height,version); 
testSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\testSet%d.txt',version);
resultFileName=sprintf('..\\..\\..\\result\\baidu\\som\\baidu_som_result_%d_%s.txt',version,date);

userLevelFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\userLevel.txt');
saveRecListFileName=sprintf('..\\..\\..\\data\\baidu\\somdata\\recList\\reclist%d.mat',version);
weightFileName = sprintf('..\\..\\..\\data\\baidu\\commondata\\weight_%dx%d_%d.mat',width,height,version);
userRatingMatrixFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\userRatingMatrix%d.mat',version);
socialTrustFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\trust200_direct%d.txt',version);
userSocialTrustCellFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\userSocialTrustCell_direct%d.mat',version);


%% ********************����֮ǰ�����õ�����**********************************

load(ratingSomFileName, 'uniqUserData', 'uniqItemData', 'itemClassIndex');
load(userRatingMatrixFileName,'userRatingMatrix');
testSet = load(testSetFileName);
socialTrustData=load(socialTrustFileName);
userLevel=load(userLevelFileName);
load(weightFileName,'local_weight','global_weight');

%% ******************���г�ʼ��***************************

userCount=length(uniqUserData);
itemCount=length(uniqItemData);
testUserData=testSet(:,1);
uniqTestUserData=unique(testUserData);
testUserCount=length(uniqTestUserData);
interestCount=size(local_weight,1);
levelNum=length(unique(userLevel(:,2)));

% һЩ��Ϊ�̶��Ĳ���
likeThreshold=4;   % �ж��û��Ƿ�ϲ��һ��item����ֵ��Ҫ������
recThreshold=0;  % ����������Ȥ�����Ƽ�ʱ����ÿ����ȤȦ�Ԥ������Ҫ���������ֵ�Żᱻ�Ƽ�
% alpha=0.5; % ��Ȥ�ϲ��Ĳ�����rating=alpha��social=1-alpha
interestCircleThreshold=0.0;  % ������Ȥ�û�����ֵ���������ֵ���û����뵽��ȤȦ
majorInterestThreshold=0.00;  % �����Ƿ�����Ҫ��Ȥ
beta = 0.10;

% ȡ���û���trust�б�
load(userSocialTrustCellFileName);
% userSocialTrustCell=GetUserSocialTrust(uniqUserData,socialTrustData);
% save(userSocialTrustCellFileName,'userSocialTrustCell');

% �������û����ֵ���ͬ��Ȥ����ȥ����ͬ��֮���û������ص�
% userInterestCircleCell=SplitUserByInterestCircle3(global_weight,cutRate);
userInterestCircleCell=SplitUserByInterestCircle(global_weight,interestCircleThreshold);

% ������item���ֵ���ͬ��Ȥ���У���֮��item���ص�
itemInterestCircleCell=SplitItemByInterestCircle(itemClassIndex,interestCount);

% ��������û�ƽ�����
userAvgRating=GetAllUserAvgRating(userRatingMatrix);

%% **** ��������� *******

%% ***************�������ü�һЩ��ʼ������*********************
topKList=(10:10:100);
socialNeighbourNum=50 ; % social friend ���������ٸ�


recListLengthRecord=[]; % ��¼һ��ÿ���û����Ƽ��б�ĳ��ȣ��������topK
% ��¼��ÿ���û����Ƽ��б�
allUserFinalRecList=cell(testUserCount,1);  
% ��¼�����û�������ָ����
allUserEvaluation=zeros(testUserCount,4);
allUserRecInfo = cell(testUserCount,1);  

totalPrecision = zeros(1,10);
totalRecall = zeros(1,10);
totalCount=0; %��Ϊ������precision,recall ,f1�ķ�ĸ
notCount = 0; % ���Լ�����û�����ִ��ڵ���4��


fprintf('start the iteration ... \n')
userRatingMatrix = sparse(userRatingMatrix);
%% *******************��ʼ����************************
parfor i=1:testUserCount
   
    the20num=round(0.2*testUserCount);
    if mod(i,the20num)==0
        disp ('20%');
    end
    %% ***********��ÿ��Ŀ���û�����һЩ��ʼ��****************
    
    % ���Ƽ��û�ID
    testUser=uniqTestUserData(i);
    % ��ѵ�����е�uniqUserData�� testuser��Ӧ��ID
    testUserID=find(uniqUserData == testUser);
 
    levelIdx=find(userLevel(:,1)==testUser);
    level=userLevel(levelIdx,2);
  
    %% *********************************������һ����ȡ��Ŀ���û����Ƽ��б�*********************
    
    %% ***********ȡ��Ŀ���û�����������Ϣ�õ�����Ȥ��Ȩ��************
    
    ratingInterestWeight=zeros(interestCount,2);
    ratingInterestWeight(:,1)=(1:interestCount);
    ratingInterestWeight(:,2)=local_weight(:,testUserID);
   
    totalGlobalInterest = global_weight(:,testUserID);
     
    % ѡ�������ֵ����Ȥ,�����Ĳ�ȥ����ֻ�Ǹ�ֵΪ0�����������
    % ########### rating interest ��ʱ������########################
%     idx=find(ratingInterestWeight(:,2) < majorInterestThreshold);
%     ratingInterestWeight(idx,2)=0;

    % ��һ��
    totalWeight1 = sum(ratingInterestWeight(:,2));
    if totalWeight1>0
        ratingInterestWeight(:,2)=ratingInterestWeight(:,2)/totalWeight1;
    end
    
    %% ***********ȡ��Ŀ���û������罻��Ϣ�õ�����Ȥ��Ȩ��*************
    
    userSocialCircle=userSocialTrustCell{testUserID};
    
    if isempty(userSocialCircle)
        socialInterestWeight=zeros(interestCount,2);
    else
        socialFriendNum = size(userSocialCircle,1);
        if socialFriendNum>socialNeighbourNum
           realSocialNeiNum = socialNeighbourNum;
        else
           realSocialNeiNum=socialFriendNum;
        end
        userSocialCircle=userSocialCircle(1:realSocialNeiNum,:);
        socialInterestWeight = GetSocialInterestWeight(userSocialCircle,local_weight,majorInterestThreshold);
        % ��һ��
        totalWeight2=sum(socialInterestWeight(:,2));
        if totalWeight2>0
            socialInterestWeight(:,2)=socialInterestWeight(:,2)/totalWeight2;
        end
    end
    
    %% ***************��Ȥ�ϲ�*************************
    mixedInterestWeight=zeros(interestCount,2);
    mixedInterestWeight(:,1)=(1:interestCount);
    mixedInterestWeight(:,2)=(1-alpha)*ratingInterestWeight(:,2)+alpha*socialInterestWeight(:,2);
%      mixedInterestWeight(:,2)=ratingInterestWeight(:,2);
%     mixedInterestWeight(:,2)=socialInterestWeight(:,2); 

    % ȥ��Ϊ0����Ȥ
    tx0=find(mixedInterestWeight(:,2)>0);
    mixedInterestWeight=mixedInterestWeight(tx0,:);
    % ��������
    mixedInterestWeight=-sortrows(-mixedInterestWeight,2);     
   
    
    % ��������Ȩ�صĺ�
    totalWeight=sum(mixedInterestWeight(:,2));
    totalInterestRecList=[];
    
    maxInterest = 15;
    simpleCount = 0;
    %% ************* ����Ŀ���û�ÿһ����Ȥ����һ���Ƽ��б���ȥ���û��Ѿ������� *********************
    for j=1:size(mixedInterestWeight,1)      
        if simpleCount>maxInterest
            continue;
        end
        simpleCount = simpleCount+1;
        
        % �����Ȩ��,����ٺϲ�����Ȥ���ϣ�Ҫ����ȥ
        tempWeight = mixedInterestWeight(j,2)/totalWeight;
        % ��ȡ�ڸ���ȤȦ�������
        userInterestCircle = userInterestCircleCell{mixedInterestWeight(j,1)};
        
        interestNo = mixedInterestWeight(j,1);
        globalPrefer = totalGlobalInterest(interestNo);
        
        % ע����ȤȦΪ�յ����
        if isempty(userInterestCircle)
            continue
        end
        % ����ȤС����ȥ���Լ�
        idx1=find(userInterestCircle(:,1) == testUserID);
        userInterestCircle(idx1,:)=[];
        % ��ȡ���ֵ�����ȤȦ��item
        itemInterestCircle=itemInterestCircleCell{mixedInterestWeight(j,1)};
        if isempty(itemInterestCircle)
            continue
        end
        % *****������Ȥ�����Ƽ�******     
        % ################### ע����ʱ����Ԥ�����ֵĴ�С������ ##########################
        interestRecList = GetRecListByInterestCircle2(testUserID,userInterestCircle,itemInterestCircle,userRatingMatrix,globalPrefer,beta);
                           
        % ����Ҫ�������Ȧ�ӵ����Ȩ��
        interestRecList(:,2)=interestRecList(:,2)*tempWeight;
               
        % �����һ����ע������item��������Ȥ���ID����ʱ���ٸĻ���
        completeInterestRecList = zeros(size(interestRecList,1),3);
        completeInterestRecList(:,1:2) = interestRecList(:,1:2);
        completeInterestRecList(:,3) = mixedInterestWeight(j,1);
        % ���ܸ�����ȤȦ�ӵĽ��
        
        totalInterestRecList=[totalInterestRecList; completeInterestRecList];
    end   
    
     % ��¼һ��ÿ���û����Ƽ��б�ĳ��ȣ��������topK
    recListLengthRecord=[recListLengthRecord; [testUser size(totalInterestRecList,1)]];
    
   finalRecList = cell(10,1);
    % �Ժϲ�����Ƽ��б���ָߵͽ������򣬽�������
    if ~isempty(totalInterestRecList)
        totalInterestRecList=-sortrows(-totalInterestRecList,2);
         % ȥ��testUser�Ѿ�������
        watchedItemList=find(userRatingMatrix(testUserID,:)>0);
        [c,ia]=intersect(totalInterestRecList(:,1),watchedItemList);
        totalInterestRecList(ia,:)=[];
         % ��topK�����ã������Ͳ�����
         
        for m = 1:10
            if length(totalInterestRecList(:,1))<topKList(m)
                realTopK = length(totalInterestRecList(:,1));
                finalRecList{m}= totalInterestRecList(1:realTopK,1);
            else
                finalRecList{m} = totalInterestRecList(1:topKList(m),1);
            end
        end
        
    end
       
    
    %% **********************************�����ڶ�����ȡ�ò��Լ���Ŀ���û�ϲ����item�б�***********************
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
    
    %% **************************************�����������������Ƽ�Ч��****************************************
    % ���Ƽ��б�Ͳ��Լ����û�ϲ����itemȡ��������Ϊhit����
    precisionList= [];
    recallList = [];
    infoCell = cell(1,6);
    for m = 1:10
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
        if m==5
            allUserEvaluation(i,:)=[testUser,precision,recall,level];           
            infoCell{1} = testUser;
            infoCell{2} = hitList;
            infoCell{3} = length(testUserLikedItemList);
            infoCell{4} = mixedInterestWeight(:,1);
            infoCell{5} = level;
            infoCell{6} = topKList(m);
        end
    end
    
    totalPrecision = totalPrecision + precisionList;
    totalRecall = totalRecall + recallList;
        
    % ��¼ÿ���û������յ��Ƽ��б�
    recListCell=cell(1,2);
    recListCell{1}=testUser;
    recListCell{2}=finalRecList{5};
    allUserFinalRecList{i}=recListCell;
       
    allUserRecInfo{i} = infoCell;
             
    % �ܵ����ģ�����+1�������Ϊ��ĸ
    totalCount=totalCount+1;
    
    
end

%% #####################����ָ��###########################

avgPrecision=totalPrecision/totalCount;
avgRecall=totalRecall/totalCount;
avgF1=2*avgPrecision.*avgRecall./(avgPrecision+avgRecall);

%����������Level�û��� ׼ȷ�� �ٻ��� F1
% avgUserEvaluationByLevel = EvaluationAnalysis(allUserEvaluation, levelNum);
avgTwoEvaluation=OnlyTwoEvaluation(allUserEvaluation);

itemPopularity = GetItemPopularity(userRatingMatrix);
[coverage,novelty] =  NewDiversityAnalysis(allUserFinalRecList,itemPopularity,itemCount,userCount);

% **********final ʵ���� ***************
for m = 1:5
    topK = topKList(m);
    finalResultFileName=sprintf('..\\..\\..\\result\\baidu\\som\\cmim\\final_baidu_cmim_prf_top%d_alpha%.1f.txt',topK,alpha);
    fid = fopen(finalResultFileName,'a');
    fprintf(fid,'%f\t%f\t%f\r\n',avgPrecision(m),avgRecall(m),avgF1(m));
    fclose(fid);
end

finalDiversityFileName=sprintf('..\\..\\..\\result\\baidu\\som\\cmim\\final_baidu_cmim_diversity_alpha%.1f.txt',alpha);
finalColdUserResultFileName = sprintf('..\\..\\..\\result\\baidu\\som\\cmim\\final_baidu_cmim_colduser_alpha%.1f.txt',alpha);


fid = fopen(finalDiversityFileName,'a');
fprintf(fid,'%f\t%f\r\n',coverage,novelty);
fclose(fid);

fid = fopen(finalColdUserResultFileName,'a');
fprintf(fid,'%f\t%f\t%f\r\n',avgTwoEvaluation(1,2),avgTwoEvaluation(1,3),avgTwoEvaluation(1,4));
fclose(fid);




end
end




toc;

