function cost = GetCost_flixster(R, Q, P,lambda, beta, wm, rm, trainSet,uniqUserData ,uniqItemData,userSocialTrustCell)

% error = sqrt(sum(sum((W.*(R - rm - Q * P')).^2)));
userCount = size(Q,1);
itemCount = size(P,1);
trainCount = size(trainSet,1);
cost = 0;

parfor uid = 1 : userCount
    
    temp = wm * sum( (R(uid,:) - rm -Q(uid,:) * P' ).^2);
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
    
    cost = cost + temp + userBias + beta * socialBias;
end

parfor i = 1: trainCount
        trainCase = trainSet(i,:);
        user = trainCase(1);
        uid = find(uniqUserData == user);
        item = trainCase(2);
        iid = find(uniqItemData == item);      
        rating = trainCase(3); 
        ratingError =  rm + Q(uid, :) * P(iid, :)'  - rating;
        biasRatingError = rm + Q(uid, :) * P(iid, :)'; % 没打分的error
        cost = cost - wm * biasRatingError^2;   % 除去没打分 带来的cost
        cost = cost + ratingError^2;
end

parfor iid = 1: itemCount
    itemBias = lambda * P(iid, :) * P(iid, :)';
    cost = cost + itemBias;
end


end