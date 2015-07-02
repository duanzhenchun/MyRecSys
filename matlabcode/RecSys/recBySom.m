% 根据将用户对每个聚类的喜爱度和该聚类里item的平均评分相乘，排序，
% 取TOP-N

clear;
load  ratingSomByZero5 net  UserRatingMatrix itemAvgRating weight itemClass itemClassIndex userCount itemCount uniqUserData uniqItemData;

finalRecord=zeros(40,3);
finalRecord(:,1)=(5:5:200);

for p=1:size(finalRecord,1);
    if mod(p,8)==0
        disp('20%');
    end
    N=finalRecord(p,1);  % topN value
    weight=weight/5;
    
    % 因为som训练后的集合在序数上和之前的不对应，
    % 所以要做用户映射
    % 第1列为新的序数，范围是1~userCount，第2列为旧的序数，范围1~566
    userNumMap=zeros(userCount,2);
    for m=1:userCount
        userNumMap(m,1)=m;
        userNumMap(m,2)=uniqUserData(m);
    end
    
    % 同样item也要做映射
    % 第1列为新的序数，第2列为旧的序数
    itemNumMap=zeros(itemCount,2);
    
    for m=1:itemCount
        itemNumMap(m,1)=m;
        itemNumMap(m,2)=uniqItemData(m);
    end
    
    
    TestSet= load('f:\BaiduProject\mydata1\set\TestSet5.txt');
    testUserData=TestSet(:,1);
    uniqTestUserData=unique(testUserData);
    testUserCount=length(uniqTestUserData);
    
    % disp(testUserCount);
    
    totalCount=0;
    totalPrecision=0;
    totalRecall=0;
       
    % 针对每个用户进行推荐
    % for i=1:testUserCount
    for i=1:testUserCount
        testUserID=uniqTestUserData(i); % 测试集用户ID
        [tx,ty]= find(userNumMap(:,2)==testUserID);
        if(isempty(tx))
            continue;
        end
        %  测试集用户ID对应训练集旧ID，转换成新ID
        trainUserID=userNumMap(tx,1);
        [wx,wy]=find(weight(:,trainUserID)>0);
        if(isempty(wx)) %用户没有喜欢的item集合，就略过
            continue;
        end
        totalItemRecCollec=zeros(N,2); % 最后要推荐的item集合
        
        for k=1:length(wx)
            tempWeight=weight(wx(k),trainUserID);
            % my 是item的序号
            [mx,my]=find(itemClassIndex==wx(k));
            %第1列是item序号，第2列是item评分
            tempItemCollec=zeros(length(my),2);
            % 给新的item序号做映射，得到之前的准确的item序号
            origItemIndex=itemNumMap(my,2);
            tempItemCollec(:,1)=origItemIndex;
            tempItemCollec(:,2)=itemAvgRating(origItemIndex);
            tempItemCollec(:,2)=tempItemCollec(:,2)*tempWeight;
            tempItemCollec=sort(tempItemCollec,'descend');
            tempItemCollec=-sortrows(-tempItemCollec,2);
            
            %处理nan
            [nanx,nany]=find(isnan(tempItemCollec(:,2))==1);
            if(~isempty(nanx))
                tempItemCollec(nanx,:)=[];
            end
            if size(tempItemCollec,1) >N
                tempItemCollec=tempItemCollec(1:N,:);
            end
            
            %第一个值是最大的，但如果加不进去，那么后面的都不用加了,
            % 注意 等于号， 这个位置可以调，可能会影响推荐结果，等于的话也不加入
            [a,b]=find(totalItemRecCollec(:,2)<tempItemCollec(1,2));
            if(isempty(a))
                continue;
            end
            
            %向推荐列表进行插入和比较
            for j=1:size(tempItemCollec,1)
                [jx,jy]=find(ismember(tempItemCollec(j,1),totalItemRecCollec(:,1))==1);
                % 有重合的话
                if(~isempty(jx))
                    if totalItemRecCollec(jx,2)<tempItemCollec(j,2)
                        totalItemRecCollec(jx,2)=tempItemCollec(j,2);
                        totalItemRecCollec=-sortrows(-totalItemRecCollec,2);
                    end
                    continue;
                    % 没有重合的话
                else
                    [c,d]=find(totalItemRecCollec(:,2)<tempItemCollec(j,2));
                    if(~isempty(c))
                        %                    disp('total');
                        %                    disp(totalItemRecCollec);
                        %                     disp('temp');
                        %                    disp(tempItemCollec(j,:));
                        totalItemRecCollec=[totalItemRecCollec;tempItemCollec(j,:) ];
                        %                     disp('combined');
                        %                    disp(totalItemRecCollec);
                        totalItemRecCollec=-sortrows(-totalItemRecCollec,2);
                        totalItemRecCollec=totalItemRecCollec(1:N,:);
                    else
                        %后面的更小，加不进去了，所以break
                        break;
                    end
                end
            end
        end
        [rx,ry]=find(TestSet(:,1)==testUserID);
        %用户真实喜欢的item集合
        realItemCollec=TestSet(rx,2);
        %交集
        hitCollec=intersect(realItemCollec,totalItemRecCollec(:,1));
        %     disp('hit item');
        %     disp(hitCollec);
        precision=length(hitCollec)/N;
        recall=length(hitCollec)/length(realItemCollec);
        %总计
        totalCount=totalCount+1;
        totalPrecision=totalPrecision+precision;
        totalRecall=totalRecall+recall;
%         if mod(totalCount,100)==0
%             disp('20%');
%         end
    end
        %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   % 这个地方计算有问题  分母不应是全部的数量，是喜欢的，要改！
    avgPrecision=totalPrecision/totalCount;
    avgRecall=totalRecall/totalCount;
    

    finalRecord(p,2)=avgPrecision;
    finalRecord(p,3)=avgRecall;
    
   
    
end











