function cost = GetCost_baidu(R, Q, P, W, rm, lambda, beta, userSocialTrustCell)

% cost = sqrt(sum(sum((W.*(R - rm - Q * P')).^2)));

userCount = size(Q,1);
itemCount = size(P,1);
cost= 0;

parfor uid = 1 : userCount
    
    ratingBias = sum( W(uid,:).* (R(uid,:) - rm -Q(uid,:) * P' ).^2);
    userBias = lambda * Q(uid,:) * Q(uid, :)';
    
    socialCircleU = userSocialTrustCell{uid};   
    if isempty(socialCircleU)
        socialBias = 0;
    else
        socialError = Q(uid, :);
        vidList = socialCircleU(:,1);   
        for i = 1: length(vidList)
            vid = vidList(i);
            socialError = socialError - socialCircleU(i,2) * Q(vid, :);
        end
        socialBias = socialError * socialError';
    end
    
    cost = cost + ratingBias + userBias + beta * socialBias;
end


parfor iid = 1: itemCount
    itemBias = lambda * P(iid, :) * P(iid, :)';
    cost = cost + itemBias;
end



end