function userSocialTrustCell=GetUserSocialTrust(uniqUserData,socialTrustData)

    userCount=length(uniqUserData);
    userSocialTrustCell=cell(userCount,1);
    fprintf('start to get the trust ...');
    
    for i=1:userCount
        
        the20num=round(0.2*userCount);
        if mod(i,the20num)==0
            disp ('20%');
        end
        
        tempUser=uniqUserData(i);
        idx=find(socialTrustData(:,1)==tempUser);
        trustNeighbour=socialTrustData(idx,2);
        trustValues=socialTrustData(idx,3);   
        
        [C,IA,IB]=intersect(uniqUserData,trustNeighbour);
        indexList=zeros(length(trustNeighbour),2);
        indexList(:,1)=IA;
        indexList(:,2)=IB;
        %∞¥indexBµƒ…˝–Ú≈≈¡–
        indexList=sortrows(indexList,2);
        
        trustList=zeros(length(idx),2);
        trustList(:,1)=indexList(:,1);
        trustList(:,2)=trustValues;
        userSocialTrustCell{i}=trustList;
    end


end