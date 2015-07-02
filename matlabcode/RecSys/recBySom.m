% ���ݽ��û���ÿ�������ϲ���Ⱥ͸þ�����item��ƽ��������ˣ�����
% ȡTOP-N

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
    
    % ��Ϊsomѵ����ļ����������Ϻ�֮ǰ�Ĳ���Ӧ��
    % ����Ҫ���û�ӳ��
    % ��1��Ϊ�µ���������Χ��1~userCount����2��Ϊ�ɵ���������Χ1~566
    userNumMap=zeros(userCount,2);
    for m=1:userCount
        userNumMap(m,1)=m;
        userNumMap(m,2)=uniqUserData(m);
    end
    
    % ͬ��itemҲҪ��ӳ��
    % ��1��Ϊ�µ���������2��Ϊ�ɵ�����
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
       
    % ���ÿ���û������Ƽ�
    % for i=1:testUserCount
    for i=1:testUserCount
        testUserID=uniqTestUserData(i); % ���Լ��û�ID
        [tx,ty]= find(userNumMap(:,2)==testUserID);
        if(isempty(tx))
            continue;
        end
        %  ���Լ��û�ID��Ӧѵ������ID��ת������ID
        trainUserID=userNumMap(tx,1);
        [wx,wy]=find(weight(:,trainUserID)>0);
        if(isempty(wx)) %�û�û��ϲ����item���ϣ����Թ�
            continue;
        end
        totalItemRecCollec=zeros(N,2); % ���Ҫ�Ƽ���item����
        
        for k=1:length(wx)
            tempWeight=weight(wx(k),trainUserID);
            % my ��item�����
            [mx,my]=find(itemClassIndex==wx(k));
            %��1����item��ţ���2����item����
            tempItemCollec=zeros(length(my),2);
            % ���µ�item�����ӳ�䣬�õ�֮ǰ��׼ȷ��item���
            origItemIndex=itemNumMap(my,2);
            tempItemCollec(:,1)=origItemIndex;
            tempItemCollec(:,2)=itemAvgRating(origItemIndex);
            tempItemCollec(:,2)=tempItemCollec(:,2)*tempWeight;
            tempItemCollec=sort(tempItemCollec,'descend');
            tempItemCollec=-sortrows(-tempItemCollec,2);
            
            %����nan
            [nanx,nany]=find(isnan(tempItemCollec(:,2))==1);
            if(~isempty(nanx))
                tempItemCollec(nanx,:)=[];
            end
            if size(tempItemCollec,1) >N
                tempItemCollec=tempItemCollec(1:N,:);
            end
            
            %��һ��ֵ�����ģ�������Ӳ���ȥ����ô����Ķ����ü���,
            % ע�� ���ںţ� ���λ�ÿ��Ե������ܻ�Ӱ���Ƽ���������ڵĻ�Ҳ������
            [a,b]=find(totalItemRecCollec(:,2)<tempItemCollec(1,2));
            if(isempty(a))
                continue;
            end
            
            %���Ƽ��б���в���ͱȽ�
            for j=1:size(tempItemCollec,1)
                [jx,jy]=find(ismember(tempItemCollec(j,1),totalItemRecCollec(:,1))==1);
                % ���غϵĻ�
                if(~isempty(jx))
                    if totalItemRecCollec(jx,2)<tempItemCollec(j,2)
                        totalItemRecCollec(jx,2)=tempItemCollec(j,2);
                        totalItemRecCollec=-sortrows(-totalItemRecCollec,2);
                    end
                    continue;
                    % û���غϵĻ�
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
                        %����ĸ�С���Ӳ���ȥ�ˣ�����break
                        break;
                    end
                end
            end
        end
        [rx,ry]=find(TestSet(:,1)==testUserID);
        %�û���ʵϲ����item����
        realItemCollec=TestSet(rx,2);
        %����
        hitCollec=intersect(realItemCollec,totalItemRecCollec(:,1));
        %     disp('hit item');
        %     disp(hitCollec);
        precision=length(hitCollec)/N;
        recall=length(hitCollec)/length(realItemCollec);
        %�ܼ�
        totalCount=totalCount+1;
        totalPrecision=totalPrecision+precision;
        totalRecall=totalRecall+recall;
%         if mod(totalCount,100)==0
%             disp('20%');
%         end
    end
        %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   % ����ط�����������  ��ĸ��Ӧ��ȫ������������ϲ���ģ�Ҫ�ģ�
    avgPrecision=totalPrecision/totalCount;
    avgRecall=totalRecall/totalCount;
    

    finalRecord(p,2)=avgPrecision;
    finalRecord(p,3)=avgRecall;
    
   
    
end











