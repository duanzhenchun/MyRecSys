clear;
tic;

%% ������ v3.0 ��
% �����û���Ȥ���Ƽ�
% �ֱ���������Ϣ���罻��Ϣ���ھ��û�����Ȥ
% �ҳ��û�����Ȥ���ٻ�����Ȥ���������Ƽ�

% update:��ǿ�˶�����Ȥ�ķ���

%% **************���ļ�����ʹ洢��Ŀ¼���������趨*********************************
date='7.11';
version=1;   % �ڼ������ݼ�
width=10;height=10;

ratingSomFileName=sprintf('..\\..\\..\\data\\baidu\\somdata\\baidu_%dx%d_som%d.mat',width,height,version); 
socialTrustFileName='..\\..\\..\\data\\baidu\\commondata\\trust200.txt';
testSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\testSet%d.txt',version);
resultFileName=sprintf('..\\..\\..\\result\\baidu\\som\\baidu_som_result_%d_%s.txt',version,date);
itemSimiFileName=sprintf('..\\..\\..\\data\\baidu\\ibcfdata\\itemSimiMatrix%d.mat',version);
userLevelFileName='..\\..\\..\\data\\baidu\\commondata\\userLevel.txt';
saveRecListFileName=sprintf('..\\..\\..\\data\\baidu\\somdata\\recList\\reclist%d.mat',version);

%% ********************����֮ǰ�����õ�����**********************************

load(ratingSomFileName, 'uniqUserData', 'uniqItemData', ...
    'userRatingMatrix','weight', 'itemClassIndex');
testSet= load(testSetFileName);
socialTrustData=load(socialTrustFileName);
load(itemSimiFileName,'itemSimiMatrix');
userLevel=load(userLevelFileName);

format long;

%% ******************���г�ʼ��***************************

userCount=length(uniqUserData);
itemCount=length(uniqItemData);
testUserData=testSet(:,1);
uniqTestUserData=unique(testUserData);
testUserCount=length(uniqTestUserData);
interestCount=size(weight,1);
levelNum=length(unique(userLevel(:,2)));

% һЩ��Ϊ�̶��Ĳ���
likeThreshold=4;   % �ж��û��Ƿ�ϲ��һ��item����ֵ��Ҫ������
recThreshold=1;  % ����������Ȥ�����Ƽ�ʱ����ÿ����ȤȦ�Ԥ������Ҫ���������ֵ�Żᱻ�Ƽ�
alpha=0.5; % ��Ȥ�ϲ��Ĳ�����rating=alpha��social=1-alpha
interestCircleThreshold=0.2;  %������Ȥ�û�����ֵ���������ֵ���û����뵽��ȤȦ
majorInterestThreshold=0.05; % �����Ƿ�����Ҫ��Ȥ

ratingNumThreshold=10;

% ȡ���û���trust�б�
userSocialTrustCell=GetUserSocialTrust(uniqUserData,socialTrustData);

% % �������û����ֵ���ͬ��Ȥ����ȥ����ͬ��֮���û������ص�
userInterestCircleCell=SplitUserByInterestCircle(weight,interestCircleThreshold);

% �������û����ֵ���ͬ��Ȥ����ȥ����ͬ��֮���û������ص�
% userInterestCircleCell=SplitUserByInterestCircle2(weight,userRatingMatrix,itemClassIndex,ratingNumThreshold);

% ������item���ֵ���ͬ��Ȥ���У���֮��item���ص�
itemInterestCircleCell=SplitItemByInterestCircle(itemClassIndex,interestCount);
% ��������û�ƽ�����
userAvgRating=GetAllUserAvgRating(userRatingMatrix);

%% **** ��������� *******
% topKList=(10:10:100);
% socialNeighbourNumList=(10:10:100);
% for iter1=1:length(topKList)
% topK=topKList(iter1);
% for iter2=1:length(socialNeighbourNumList)
% socialNeighbourNum=socialNeighbourNumList(iter2);
%% ***************�������ü�һЩ��ʼ������*********************
topK=50;           % �����Ƽ��б�ǰtopK��
socialNeighbourNum=20;

recListLengthRecord=[]; % ��¼һ��ÿ���û����Ƽ��б�ĳ��ȣ��������topK

% ��¼��ÿ���û����Ƽ��б�
allUserFinalRecList=cell(testUserCount,1);  
% ��¼�����û�������ָ����
allUserEvaluation=ones(length(testUserCount),4)*(-100);
% ��¼ÿ���û�����Ȥ
allUserInterestSet=cell(testUserCount,1);

totalPrecision=0; totalRecall=0; 
%��Ϊ������precision,recall ,f1�ķ�ĸ
totalCount=0;

fprintf('start the iteration ...')
specialCount1=0;
specialCount2=0;
specialCount3=0;
totalAvgHitRank=0;
totalClassNum=0;
%% *******************��ʼ����************************
parfor i=1:testUserCount
% for i=1158
%     disp(i);
    the20num=round(0.2*testUserCount);
    if mod(i,the20num)==0
        disp ('20%');
    end
    %% ***********��ÿ��Ŀ���û�����һЩ��ʼ��****************
    
    % ���Ƽ��û�ID
    testUser=uniqTestUserData(i);
    % ��ѵ�����е�uniqUserData�� testuser��Ӧ��ID
    testUserID=find(uniqUserData==testUser);
        
    %% *********************************������һ����ȡ��Ŀ���û����Ƽ��б�*********************
    
    %% ***********ȡ��Ŀ���û�����������Ϣ�õ�����Ȥ��Ȩ��************
    
    ratingInterestWeight=zeros(interestCount,2);
    ratingInterestWeight(:,1)=(1:interestCount);
    ratingInterestWeight(:,2)=weight(:,testUserID);
   
    % ѡ�������ֵ����Ȥ,�����Ĳ�ȥ����ֻ�Ǹ�ֵΪ0�����������
    idx=find(ratingInterestWeight(:,2)<majorInterestThreshold);
    ratingInterestWeight(idx,2)=0;
    
    % ��ȫΪ0����û��Ҫ��һ��
    if length(idx)<interestCount
        % ��һ��
        totalWeight1=sum(ratingInterestWeight(:,2));
        ratingInterestWeight(:,2)=ratingInterestWeight(:,2)/totalWeight1;
    end
    
    %% ***********ȡ��Ŀ���û������罻��Ϣ�õ�����Ȥ��Ȩ��*************
    
    userSocialCircle=userSocialTrustCell{testUserID};
    userSocialCircle=userSocialCircle(1:socialNeighbourNum,:);
    socialInterestWeight=GetSocialInterestWeight(userSocialCircle,weight,majorInterestThreshold);
    % ��һ��
    totalWeight2=sum(socialInterestWeight(:,2));
    if totalWeight2>0
        socialInterestWeight(:,2)=socialInterestWeight(:,2)/totalWeight2;
    end
    
    %% ***************��Ȥ�ϲ�*************************
    mixedInterestWeight=zeros(interestCount,2);
    mixedInterestWeight(:,1)=(1:interestCount);
    mixedInterestWeight(:,2)=alpha*ratingInterestWeight(:,2)+(1-alpha)*socialInterestWeight(:,2);
%     mixedInterestWeight(:,2)=socialInterestWeight(:,2);

    % ȥ��Ϊ0����Ȥ
    tx0=find(mixedInterestWeight(:,2)>0);
    mixedInterestWeight=mixedInterestWeight(tx0,:);
    % ��������
    mixedInterestWeight=-sortrows(-mixedInterestWeight,2);     
    % ��������Ȩ�صĺ�
    totalWeight=sum(mixedInterestWeight(:,2));
    totalInterestRecList=[];
    otherInterestRecList=[];
    remain=topK;
    %% ************* ����Ŀ���û�ÿһ����Ȥ����һ���Ƽ��б���ȥ���û��Ѿ������� *********************
    for j=1:size(mixedInterestWeight,1)
        
        % �����Ȩ��,����ٺϲ�����Ȥ���ϣ�Ҫ����ȥ
        tempWeight=mixedInterestWeight(j,2)/totalWeight;
        % ��ȡ�ڸ���ȤȦ�������
        userInterestCircle=userInterestCircleCell{mixedInterestWeight(j,1)};
        % ע����ȤȦΪ�յ����
        if isempty(userInterestCircle)
            continue
        end
        % ����ȤС����ȥ���Լ�
        idx1=find(userInterestCircle(:,1)==testUserID);
        userInterestCircle(idx1,:)=[];
        % ��ȡ���ֵ�����ȤȦ��item
        itemInterestCircle=itemInterestCircleCell{mixedInterestWeight(j,1)};
        if isempty(itemInterestCircle)
            continue
        end
        % *****������Ȥ�����Ƽ�******     
        interestRecList=GetRecListByInterestCircle(testUserID,userInterestCircle,itemInterestCircle,userRatingMatrix,recThreshold,userAvgRating);
        
        % ��2�׷����������⣬��ʱ��ʹ��
        %interestRecList=GetRecListByInterestCircle2(testUserID,userInterestCircle,itemInterestCircle,userRatingMatrix,recThreshold,userAvgRating);
        
        interestRecList(:,2)=interestRecList(:,2)/5;  % ��һ��
        
        % ����Ҫ�������Ȧ�ӵ����Ȩ��
        interestRecList(:,2)=interestRecList(:,2)*tempWeight;
       
%         interestRecList(:,2)=3*interestRecList(:,2)*tempWeight./(interestRecList(:,2)+2*tempWeight);
        
        % �����һ����ע������item��������Ȥ���ID����ʱ���ٸĻ���
        completeInterestRecList=zeros(size(interestRecList,1),3);
        completeInterestRecList(:,1:2)=interestRecList;
        completeInterestRecList(:,3)=mixedInterestWeight(j,1);
        % ���ܸ�����ȤȦ�ӵĽ��
        %         totalInterestRecList=[totalInterestRecList;interestRecList];
        totalInterestRecList=[totalInterestRecList; completeInterestRecList];
        
%         if remain==0
%             continue;
%         end        
%          % ȥ��testUser�Ѿ�������
%         watchedItemList=find(userRatingMatrix(testUserID,:)>0);
%         [c,ia]=intersect(completeInterestRecList(:,1),watchedItemList);
%         completeInterestRecList(ia,:)=[];
%               
%         recLens=min([round(tempWeight*topK)+1,length(completeInterestRecList(:,1)),remain]);
%         otherRecList=completeInterestRecList(1:recLens,:);
%         otherInterestRecList=[otherInterestRecList; otherRecList];
%         remain=remain-recLens;       
        
    end   
    
%     totalInterestRecList=otherInterestRecList;
    
    if isempty(totalInterestRecList)
        specialCount1=specialCount1+1;
        continue
    end
    % �Ժϲ�����Ƽ��б���ָߵͽ������򣬽�������
    totalInterestRecList=-sortrows(-totalInterestRecList,2);
    
    % ȥ��testUser�Ѿ�������
    watchedItemList=find(userRatingMatrix(testUserID,:)>0);
    [c,ia]=intersect(totalInterestRecList(:,1),watchedItemList);
    totalInterestRecList(ia,:)=[];
    

    % ��¼һ��ÿ���û����Ƽ��б�ĳ��ȣ��������topK
    if size(totalInterestRecList,1)>0
        recListLengthRecord=[recListLengthRecord size(totalInterestRecList,1)];
    end
      
    % ��topK�����ã������Ͳ�����
    if length(totalInterestRecList(:,1))<topK
        realTopK=length(totalInterestRecList(:,1));
        finalRecList=totalInterestRecList(1:realTopK,1);
        diverseClassNum=length(unique(totalInterestRecList(1:realTopK,3)));
    else
        finalRecList=totalInterestRecList(1:topK,1);
        diverseClassNum=length(unique(totalInterestRecList(1:topK,3)));
    end
    
    if isempty(finalRecList)
        % ���Ƽ�����Ϊ�գ�������Ƽ�
        specialCount2=specialCount2+1;
        continue;
    end
 
    %% **********************************�����ڶ�����ȡ�ò��Լ���Ŀ���û�ϲ����item�б�***********************
    % �����ִ���likeThreshold��ʾϲ��
    tempIndex=find(testSet(:,1)==testUser & testSet(:,3)>=likeThreshold);
    tempItemSet=testSet(tempIndex,2);
    
    [commonItem,IA,IB]=intersect(uniqItemData,tempItemSet);
    testUserLikedItemList=IA;
        
    if isempty(testUserLikedItemList)
        % ���Լ��û���û�����ִ���3��item���򲻿�������û����Ƽ��������Ƽ�
        specialCount3=specialCount3+1;
        continue;
    end
    
    %% **************************************�����������������Ƽ�Ч��****************************************
    % ���Ƽ��б�Ͳ��Լ����û�ϲ����itemȡ��������Ϊhit����
    [hitList,iia,iib]=intersect(finalRecList,testUserLikedItemList);
    if ~isempty(hitList)
        tempAvgHitRank=sum(iia)/length(iia);
        totalAvgHitRank=totalAvgHitRank+tempAvgHitRank;
    end
    if isempty(finalRecList) || isempty(testUserLikedItemList)
        disp('there is something wrong with the finalRecList or the testUserLikedItemList');
        continue;
    end
    % ���㵥���û���precision��recall
    precision=length(hitList)/length(finalRecList);
    recall=length(hitList)/length(testUserLikedItemList);
    if isnan(recall) || isnan(precision)
        disp('there is something wrong with the recall or the precision');
    end
    totalPrecision=totalPrecision+precision;
    totalRecall=totalRecall+recall;  
    
    % ����һЩ��Ȥ������������Ҫ��
    userInterestSet=zeros(interestCount,7);
    userInterestSet(:,1)= ratingInterestWeight(:,2)>0;  %������Ȥ
    userInterestSet(:,2)= socialInterestWeight(:,2)>0;  %�罻��Ȥ
    combineInterest= userInterestSet(:,1)+userInterestSet(:,2);
    userInterestSet(:,3)=combineInterest==2 ;          % �������罻�غ���Ȥ
    extraInterest= userInterestSet(:,2)-userInterestSet(:,1);
    userInterestSet(:,4)= extraInterest==-1 ;  %���ֵĶ�����Ȥ
    userInterestSet(:,5)= extraInterest==1;    %�罻�Ķ�����Ȥ;
    
    %����hitList��������Ȥ
    interestHit=GetItemInterest(hitList,itemClassIndex,interestCount);
    userInterestSet(:,6)=interestHit;
    userInterestSet(:,7)=testUser;
    allUserInterestSet{i}=userInterestSet;
       
    levelIdx=find(userLevel(:,1)==testUser);
    if isempty(levelIdx)
        level=0;
    else
        level=userLevel(levelIdx,2);
    end
    allUserEvaluation(i,:)=[testUser,precision,recall,level];
        
    % ��¼ÿ���û������յ��Ƽ��б�
    recListCell=cell(1,2);
    recListCell{1}=testUser;
    recListCell{2}=finalRecList;
    allUserFinalRecList{i}=recListCell;
       
    totalClassNum=totalClassNum+diverseClassNum;
    % �ܵ����ģ�����+1�������Ϊ��ĸ
    totalCount=totalCount+1;
    
    
end

%% #####################����ָ��###########################
avgClassNum=totalClassNum/totalCount;
avgHitRank=totalAvgHitRank/totalCount;
%����������Level�û��� ׼ȷ�� �ٻ��� F1
% avgUserEvaluationByLevel=EvaluationAnalysis(allUserEvaluation,levelNum);

% ��������Level�û��Ƽ����Ͳ��Լ�֮�����Ȥ�ĸ��ǹ�ϵ
% [avgUserRecTestItrByLevel,avgExRecTestItrRate]=RecTestSetInterestAnalysis(allUserFinalRecList,testSet,uniqItemData,likeThreshold,itemClassIndex,interestCount,userLevel);
% avgExRecItrHitNumRate=avgExRecTestItrRate(1);
% avgExTestItrHitNumRate=avgExRecTestItrRate(2);

% �������е�item��������Ȥ�У���Щ����������Ȥ����Щ�����罻��Ȥ
% avgUserItrHitNumRateByLevel=HitInterestAnalysis(allUserInterestSet,testUserCount,userLevel);

avgPrecision=totalPrecision/totalCount;
avgRecall=totalRecall/totalCount;
avgF1=2*avgPrecision*avgRecall/(avgPrecision+avgRecall);
allRecListSet=[];

totalILS=0;
acount=0;
for i=1:testUserCount
    recListCell=allUserFinalRecList{i};
    if isempty(recListCell)
        continue
    end
    recList=recListCell{2};
    allRecListSet=[allRecListSet recList'];   
    if length(recList)>1                   
        tempILS=GetIntraListSimi(recList,itemSimiMatrix);
        totalILS=totalILS+tempILS;   
        acount=acount+1;       
    end  
end
avgILS=totalILS/acount;  % ������
uniqueAllRecListSet=unique(allRecListSet);
coverage=length(uniqueAllRecListSet)/itemCount;  % ������

resultStr=sprintf('the avgPrecision is %f, the avgRecall is %f, avgF1 is %f, coverage is %f, average ILS is %f',avgPrecision,avgRecall,avgF1,coverage,avgILS);
disp(resultStr);
% ����topK���컨�壬�����ĸ�ֵ���Ͳ�����ȡ��
topKCeil= min(recListLengthRecord);

%% *************���������*****************

fid = fopen(resultFileName,'a');
fprintf(fid,'--------------------------- parameter ---------------------------------\r\n');
fprintf(fid,'topK = %d,likeThreshold= %i ,recThreshold= %1.2f ,socialNeighbour= %d, alpha=%f,interestCircleThreshold=%f,majorInterestThreshold= %f,width=%d,height=%d \r\n',topK,likeThreshold,recThreshold,socialNeighbourNum,alpha,interestCircleThreshold,majorInterestThreshold,width,height);
fprintf(fid,'--------------------------- result ----------------------------------\r\n');
fprintf(fid,'the avgPrecision is %1.7f, the avgRecall is %1.7f, the avgF1 is %1.7f ,the coverage is %f, the avgILS is %f \r\n',avgPrecision,avgRecall,avgF1,coverage,avgILS);
fprintf(fid,'--------------------------  other record ------------------------------\r\n');
fprintf(fid,'the topK ceil is %i \r\n',topKCeil);
fprintf(fid,'the totalCount is %d \r\n',totalCount);
fprintf(fid,'--------------------- cutoff line ----------------------- \r\n\r\n');
fclose(fid);

%�����Ƽ��б��Ա�֮����з���
% save(saveRecListFileName,'allUserFinalRecList');
% end
% end

toc;

