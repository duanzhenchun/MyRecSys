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
% ֻҪ��ȤС��һ����ֵ�Ͳ�����
zeroIndex=userSocialWeightSet<majorInterestThreshold;
userSocialWeightSet(zeroIndex)=0;
userTrustValueSet(zeroIndex)=0;
%���϶�Ӧ��trustֵ 
userSocialWeightSet=userSocialWeightSet.*userTrustValueSet;
% ��Ȩƽ��
socialInterestWeight(:,2)=sum(userSocialWeightSet,2)./sum(userTrustValueSet,2);
% ȥ�����ĸΪ0������ nan
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
%         % ֻҪ��ȤС��һ����ֵ�Ͳ�����
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
% % ��Ȩƽ��
% socialInterestWeight(:,2)=socialInterestWeight(:,2)./socialInterestWeight(:,3);
% 
% % ��trustֵΪ0�����ʱ��ĸΪ0�������������NaN
% % ��������û��trust�����������Ӧ��Ȥֵȫ����Ϊ0����ֹ����NaN
% idx=find(socialInterestWeight(:,3)==0);
% socialInterestWeight(idx,2)=0;
% % ȥ�������У�û����
% socialInterestWeight(:,3)=[];

    
end




