function cost = GetCost_baidu(R, Q, P, W, rm, lambda)

% cost = sqrt(sum(sum((W.*(R - rm - Q * P')).^2)));
userCount = size(Q, 1);
itemCount = size(P, 1);
cost= 0;

parfor uid = 1 : userCount
    ratingBias = sum( W(uid,:).* (R(uid,:) - rm -Q(uid,:) * P' ).^2);
    userBias = lambda * Q(uid,:) * Q(uid, :)';
    cost = cost + ratingBias + userBias;
end


parfor iid = 1: itemCount
    itemBias = lambda * P(iid, :) * P(iid, :)';
    cost = cost + itemBias;
end