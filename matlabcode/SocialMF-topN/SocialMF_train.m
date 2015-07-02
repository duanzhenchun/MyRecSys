function [U,V] = SocialMF_train(trainSet,userCount, itemCount,rm, wm, uniqueUser, uniqItemData, userSocialTrustCell, iterNum, factorNum, alpha, lambda,  beta, tolCost)

trainCount = size(trainSet,1);
U =  sqrt(5 - rm) * rand(userCount, factorNum,'single');
V =  sqrt(5 - rm) * rand(itemCount, factorNum,'single');
minCost = inf;

for iter = 1 : iterNum
    
%     if iterNum >30
%         alpha= 0.05;
%     end
    if iterNum >50
        alpha= 0.001;
    end
    
    fprintf('the %d th iteration \n',iter);
    Ugrad = zeros(userCount, factorNum,'single');
    Vgrad = zeros(itemCount, factorNum,'single');
    cost = 0;
    
    fprintf('the base regulation... \n')
     
%     storeCell1 = cell(userCount*itemCount,1);

%     for uid=1:userCount
%          for iid =1: itemCount
%              ratingError = rm + U(uid,:) * V(iid,:)';
%              Ugrad(uid, :) = Ugrad(uid, :) + wm * V(iid, :) * ratingError;
%              Vgrad(iid, :) = Vgrad(iid, :) + wm * U(uid, :) * ratingError;
%              cost = cost + wm * ratingError^2;             
%          end
%     end

     
      parfor uid=1:userCount       
         ratingError = rm + U(uid,:) * V';    % 1 x n
         Ugrad(uid, :) = Ugrad(uid, :) + wm * ratingError * V;  % 1 x f
%          cost = cost + sum(wm * ratingError.^2);                 
      end
      
      parfor iid = 1: itemCount
         ratingError = rm + U * V(iid,:)';    % m x 1
         Vgrad(iid, :) = Vgrad(iid, :) + wm * ratingError' * U  ;  % 1 x f
%          cost = cost + sum(wm * ratingError.^2);         
      end
      
      cost = cost + sum(sum(wm * (rm + U * V').^2));
     
    storeCell2 = cell(trainCount,1);
    parfor i = 1: trainCount
        trainCase = trainSet(i,:);
        user = trainCase(1);
        uid = find(uniqueUser == user);
        item = trainCase(2);
        iid = find(uniqItemData == item);      
        rating = trainCase(3); 
        ratingError =  rm + U(uid, :) * V(iid, :)'  - rating;
        biasRatingError = rm + U(uid, :) * V(iid, :)'; % 没打分的error
        Ugradcase = V(iid, :) * (ratingError - wm * biasRatingError) ;
        Vgradcase =  U(uid, :) * (ratingError - wm * biasRatingError);     
        tempCell = cell(4,1);
        tempCell{1} = uid;
        tempCell{2} = iid;
        tempCell{3} = Ugradcase;
        tempCell{4} = Vgradcase;
        storeCell2{i} = tempCell;
        cost = cost - wm * biasRatingError^2;   % 除去没打分 带来的cost
        cost = cost + ratingError^2;
    end
    
    for i =1: trainCount
        tempCell = storeCell2{i};
        uid = tempCell{1};
        iid = tempCell{2};
        Ugradcase = tempCell{3};
        Vgradcase = tempCell{4};
        Ugrad(uid, :) = Ugrad(uid, :) + Ugradcase;
        Vgrad(iid, :) = Vgrad(iid, :) + Vgradcase;       
    end
    
    
    
    fprintf('the user regulation... \n')
    parfor uid = 1: userCount
        
        socialCircleU = userSocialTrustCell{uid};
        if isempty(socialCircleU)
            continue;
        end
        vidList = socialCircleU(:,1);   
        socialError1 = U(uid, :);
        socialError2 = 0;
        for i = 1: length(vidList)
            vid = vidList(i);
            socialError1 = socialError1 - socialCircleU(i,2) * U(vid, :);
            socialCircleV = userSocialTrustCell{vid};
            if isempty(socialCircleV)
                continue;
            end
            widList = socialCircleV(:,1); 
            tempError = 0;
            for j = 1:length(widList)
                wid = widList(j);
                tempError = tempError + socialCircleV(j, 2) * U(wid, :);
            end
%             theUidx =find(socialCircleV(:,1)==uid);
%             theUidx 暂时用1代替，因为所有trust都是相同的值
            socialError2 = socialError2 + socialCircleV(1,2) * (U(vid, :) - tempError); 
        end
        Ugrad(uid, :) = Ugrad(uid, :) + lambda * U(uid, :);
        Ugrad(uid, :) = Ugrad(uid, :) + beta * socialError1;
        Ugrad(uid, :) = Ugrad(uid, :) - beta * socialError2;
%         cost = cost + lambda * U(uid, :) * U(uid, :)';
%         cost = cost + beta * (socialError1 * socialError1');
    end
    
    fprintf('the item regulation... \n')
    parfor iid = 1: itemCount
        Vgrad(iid, :) = Vgrad(iid, :) + lambda * V(iid, :);
%         cost = cost + lambda * V(iid, :) * V(iid, :)';
    end
    
   
    U = U - alpha * Ugrad;
    V = V - alpha * Vgrad;

    
    fprintf('the %d th iteration cost is %f \n',iter,cost);
    
    if cost > minCost
        break;
    else 
        minCost = cost;
    end
    
    if cost < tolCost
        break;
    end
    
    
end

end

