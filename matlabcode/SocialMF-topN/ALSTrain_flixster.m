function [Q,P] = ALSTrain_flixster(R, S, n_factors, n_iterations, lambda, epsilon, beta, rm, wm,trainSet,uniqUserData,uniqItemData, userSocialTrustCell,costTol)

[m,n] = size(R);
Q = randn(m, n_factors);
P = randn(n, n_factors);

W = R > 0 ;
W(W == 1 ) = 1;
% W(W == 0 ) = wm;

% Rcell = matrix2cell(R);
% RTcell = matrix2cell(R');

minCost=inf;
fprintf('initialization end\n start training\n');
costList = zeros(n_iterations,1);

for iter = 1:n_iterations
    
    uFixedMatrix = wm * P' * P;
    Qold = Q;
    IminusSmtpQold = (speye(m) - S) * Qold; % (I - S) * Qold
    IminusSt = speye(m) - S'; % I - S'
    AFixed = uFixedMatrix + (lambda + epsilon) * eye(n_factors);
    
    parfor u = 1: size(W, 1)
%         Ru=Rcell{u};
        Ru = R(u, :);
        Wu = W(u,:);
        iList = find(Ru > 0);
        WuiList =  Wu (iList);   
        WuiList(WuiList==0) = wm;      
        % A * Qu' = b'
        
        if isempty(iList)
            A = AFixed;
            b = beta * IminusSt(u,:) * IminusSmtpQold + epsilon * Qold(u,:);        
        else
%             A = uFixedMatrix - wm * P(iList,:)' * P(iList,:) ...
%                 + P(iList,:)' * diag(WuiList) * P(iList,:) ...
%                 + (lambda + epsilon) * eye(n_factors);
            A = AFixed - wm * P(iList,:)' * P(iList,:) + P(iList,:)' * diag(WuiList) * P(iList,:);
            b = (Ru(iList) - rm) * diag(WuiList) * P(iList,:)...
                + beta * IminusSt(u,:) * IminusSmtpQold...
                + epsilon * Qold(u,:);    
        end
        
        Q(u,:) = (A\b')';      
    end
    
    iFixedMatrix= wm * Q' * Q;
    parfor i = 1:size(W,2)
%         Ri = RTcell{i};
        Ri = R(:, i)';
        Wi = W(:, i);
        uList = find(Ri > 0);
        WiuList = Wi(uList);
        WiuList(WiuList==0) = wm;
        % A * P[i]' = b
        A = iFixedMatrix - wm * Q(uList,:)' * Q(uList,:) + Q(uList,:)' * diag(WiuList) * Q(uList,:) + lambda * eye(n_factors);
        b = Q(uList,:)' * diag(WiuList) * (Ri(uList)' - rm);
        P(i,:) = (A\b)';
    end

    cost = GetCost_flixster(R, Q, P,lambda,beta, wm, rm, trainSet,uniqUserData ,uniqItemData,userSocialTrustCell);
    fprintf('%d th iteration is complete , the cost is %f \n',iter,cost);
    costList(iter) = cost;
    
    
    plot(1:iter,costList(1:iter),(iter+1):n_iterations,costList((iter+1):n_iterations));
    title('cost after each epoch');
    drawnow      
     
     
     if abs(minCost - cost) < costTol
        break;
     end

    if cost > minCost
        break;
    else 
        minCost = cost;
    end
    


end
fprintf('model generation over');




end