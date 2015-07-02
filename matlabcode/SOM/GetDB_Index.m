function db_index=GetDB_Index(data,neuroMatrix,bmus)

% calculate the davies-bouldin index

% data dim x num
% neuroMatrix  dim x num 
clusterNum=size(neuroMatrix,2);
S=zeros(clusterNum,1);
M=zeros(clusterNum,clusterNum);
q=2;p=2;

for i=1:clusterNum
    clusterCent=neuroMatrix(:,i);
    clusterIdx=find(ismember(bmus,i));
    dataSize=length(clusterIdx);
    clusterData=data(:,clusterIdx);
    distances=sqrt(sum((clusterData-repmat(clusterCent,1,dataSize)).^2,2));
    distances=mean(distances.^q)^(1/q);
    S(i)=distances;
end

for i=1:clusterNum-1
    for j=i+1:clusterNum
        dist=neuroMatrix(:,i)-neuroMatrix(:,j);
        dist=(sum(dist.^p))^(1/p);
        M(i,j)=dist;
        M(j,i)=M(i,j);
    end
end

R=zeros(clusterNum,clusterNum);
r=zeros(clusterNum,1);
for i=1:clusterNum
    for j=i+1 :clusterNum
        R(i,j)=(S(i) + S(j))/M(i,j);        
    end
    r(i)=max(R(i,:));
end

db_index=mean(r);

end