function socialInterestWeight = GetSocialInterestWeight(userSocialCircle,local_weight,majorInterestThreshold)

% getInterest by social user
interestCount=size(local_weight,1);
socialInterestWeight=zeros(interestCount,2);
socialInterestWeight(:,1)=(1:interestCount);

userSocialSet=userSocialCircle(:,1);
userTrustValueSet=userSocialCircle(:,2);
userSocialWeightSet=local_weight(:,userSocialSet);
% repmat
userTrustValueSet=repmat(userTrustValueSet',interestCount,1);
% 只要兴趣小于一个阈值就不考虑
zeroIndex=userSocialWeightSet<majorInterestThreshold;
userSocialWeightSet(zeroIndex)=0;
userTrustValueSet(zeroIndex)=0;
%乘上对应的trust值 
userSocialWeightSet=userSocialWeightSet.*userTrustValueSet;
% 加权平均
socialInterestWeight(:,2)=sum(userSocialWeightSet,2)./sum(userTrustValueSet,2);
% 去除因分母为0产生的 nan
socialInterestWeight(isnan(socialInterestWeight))=0;



% 
% interestCount=size(weight,1);
% socialInterestWeight=zeros(interestCount,3);
% socialInterestWeight(:,1)=(1:interestCount);
% for j=1:size(userSocialCircle,1)
%     tempSocialUserID=userSocialCircle(j,1);
%     trust=userSocialCircle(j,2);
%     tempWeight=weight(:,tempSocialUserID);
%     for k=1:size(weight,1)
%         % 只要兴趣小于一个阈值就不考虑
%         if tempWeight(k)<majorInterestThreshold
%             continue
%         end
%         itrWeight=tempWeight(k);
%         socialInterestWeight(k,2)=socialInterestWeight(k,2)+itrWeight*trust;
%         socialInterestWeight(k,3)=socialInterestWeight(k,3)+trust;
%     end      
% end
% 
% 
% 
% % 加权平均
% socialInterestWeight(:,2)=socialInterestWeight(:,2)./socialInterestWeight(:,3);
% 
% % 若trust值为0，相除时分母为0，则相除后会出现NaN
% % 处理这种没有trust的情况，将对应兴趣值全部设为0，防止出现NaN
% idx=find(socialInterestWeight(:,3)==0);
% socialInterestWeight(idx,2)=0;
% % 去除第三列，没意义
% socialInterestWeight(:,3)=[];

    
end




