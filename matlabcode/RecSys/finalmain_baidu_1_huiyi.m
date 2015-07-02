clear;
tic;

%% ���һ�� ������


%% **************���ļ�����ʹ洢��Ŀ¼���������趨*********************************
date='10.27';
versionSum=10;

for version=1:10
% version=1;   % �ڼ������ݼ�
fprintf('---------------the current version is %d ----------------- \n',version);


width=5;
height=8;

fprintf('current map is %d x %d \n', width,height);

ratingSomFileName=sprintf('..\\..\\..\\data\\baidu\\somdata\\baidu_%dx%d_som%d.mat',width,height,version); 
testSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\testSet%d.txt',version);
userLevelFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\userLevel.txt');
saveRecListFileName=sprintf('..\\..\\..\\data\\baidu\\somdata\\recList\\reclist%d.mat',version);
weightFileName = sprintf('..\\..\\..\\data\\baidu\\commondata\\huiyi_weight_%dx%d_%d.mat',width,height,version);
userRatingMatrixFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\userRatingMatrix%d.mat',version);



%% ********************����֮ǰ�����õ�����**********************************

load(ratingSomFileName, 'uniqUserData', 'uniqItemData', 'itemClassIndex');
load(userRatingMatrixFileName,'userRatingMatrix');
testSet = load(testSetFileName);
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
alpha=0.5; % ��Ȥ�ϲ��Ĳ�����rating=alpha��social=1-alpha
interestCircleThreshold=0.0;  % ������Ȥ�û�����ֵ���������ֵ���û����뵽��ȤȦ
majorInterestThreshold=0.00;  % �����Ƿ�����Ҫ��Ȥ
beta = 0.10;
fprintf('current beta  is %f \n',beta)


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
    
  
    
    %% ***************��Ȥ�ϲ�*************************
    mixedInterestWeight=zeros(interestCount,2);
    mixedInterestWeight(:,1)=(1:interestCount);
    mixedInterestWeight(:,2)=ratingInterestWeight(:,2);


    % ȥ��Ϊ0����Ȥ
    tx0=find(mixedInterestWeight(:,2)>0);
    mixedInterestWeight=mixedInterestWeight(tx0,:);
    % ��������
    mixedInterestWeight=-sortrows(-mixedInterestWeight,2);     
   
    
    % ��������Ȩ�صĺ�
    totalWeight=sum(mixedInterestWeight(:,2));
    totalInterestRecList=[];
    
    maxInterest = 15;
    simpleCount =0;
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
        
        %  ##   huiyi ���� ####
        interestRecList = GetRecListByInterestCircle2_huiyi(testUserID,userInterestCircle,itemInterestCircle,userRatingMatrix,globalPrefer,beta);
                           
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
        if m==10
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
    recListCell{2}=finalRecList{10};
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
avgUserEvaluationByLevel = EvaluationAnalysis(allUserEvaluation, levelNum);
avgTwoEvaluation=OnlyTwoEvaluation(allUserEvaluation);

fprintf('the precision is \n')
disp(avgPrecision);
fprintf('the recall is \n')
disp(avgRecall);
fprintf('the f1 is \n')
disp(avgF1);

itemSimiFileName=sprintf('..\\..\\..\\data\\baidu\\ibcfdata\\itemSimiMatrix%d.mat',version);
load(itemSimiFileName,'itemSimiMatrix');
itemDistMatrix = 1 - itemSimiMatrix;
clear itemSimiMatrix
itemPopularity = GetItemPopularity(userRatingMatrix);
[coverage,avgILD,novelty]  =DiversityAnalysis(allUserFinalRecList,itemDistMatrix,itemPopularity,itemCount,userCount);
avgILD = avgILD/2; % range ��Ϊ 0-1
fprintf('coverage is %f, avgILD is %f,novelty is %f \n ',coverage,avgILD,novelty);
clear itemDistMatrix


% �������е�item��������Ȥ�У���Щ����������Ȥ����Щ�����罻��Ȥ
% avgUserItrHitNumRateByLevel=HitInterestAnalysis(allUserInterestSet,testUserCount,userLevel);

% ����topK���컨�壬�����ĸ�ֵ���Ͳ�����ȡ��
topKCeil= min(recListLengthRecord);

% *************���������*****************


% **********final ʵ���� ***************
for m =1 :10
    topK = topKList(m);
    finalResultFileName=sprintf('..\\..\\..\\huiyiresult\\baidu\\som\\pbmim\\final_baidu_pbmim_prf_top%d.txt',topK);

    fid = fopen(finalResultFileName,'a');
    fprintf(fid,'%f\t%f\t%f\r\n',avgPrecision(m),avgRecall(m),avgF1(m));
    fclose(fid);
end


finalDiversityFileName=sprintf('..\\..\\..\\huiyiresult\\baidu\\som\\pbmim\\final_baidu_pbmim_diversity.txt');
finalColdUserResultFileName = sprintf('..\\..\\..\\huiyiresult\\baidu\\som\\pbmim\\final_baidu_pbmim_colduser.txt');
finalHotUserResultFileName = sprintf('..\\..\\..\\huiyiresult\\baidu\\som\\pbmim\\final_baidu_pbmim_hotuser.txt');

fid = fopen(finalDiversityFileName,'a');
fprintf(fid,'%f\t%f\t%f\r\n',coverage,avgILD,novelty);
fclose(fid);

fid = fopen(finalColdUserResultFileName,'a');
fprintf(fid,'%f\t%f\t%f\r\n',avgTwoEvaluation(1,2),avgTwoEvaluation(1,3),avgTwoEvaluation(1,4));
fclose(fid);

fid = fopen(finalHotUserResultFileName,'a');
fprintf(fid,'%f\t%f\t%f\r\n',avgTwoEvaluation(2,2),avgTwoEvaluation(2,3),avgTwoEvaluation(2,4));
fclose(fid);




% end
end



toc;

