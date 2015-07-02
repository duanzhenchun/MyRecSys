function [Q,P] = ALSTrain_baidu(R, n_factors, n_iterations, lambda, rm, wm, costTol)

[m,n] = size(R);
Q = randn(m, n_factors) ;
P = randn(n, n_factors) ;

W = R > 0 ;
W(W == 1 ) = 1;
W(W == 0 ) = wm;
minCost=inf;

% Rcell = matrix2cell(R); % 每个cell里面都是行向量
% RTcell = matrix2cell(R');
fprintf('initialization end \n  start training \n');
costList =zeros(n_iterations,1);

for iter = 1: n_iterations     
    uFixedMatrix = wm * P' * P;
    parfor u =1:size(W, 1)
%        Ru=Rcell{u};
       Ru = R(u, :);
       Wu = W(u,:);
%        iList = find(R(u, :) > 0);
       iList = find(Ru > 0);
       % A * Q[u]' = b
       if isempty(iList)
           A  = uFixedMatrix + lambda * eye(n_factors);
           b = zeros(n_factors,1);   
       else
           A = uFixedMatrix - wm * P(iList, :)' * P(iList, :) + P(iList, :)' * diag(Wu(iList)) * P(iList, :)+ lambda * eye(n_factors);
           b = P(iList,:)' * diag(Wu(iList)) * (Ru(iList)' - rm);   
       end    
       Q(u,:) = (A\b)';
       
    end   
    
    iFixedMatrix= wm * Q' * Q;
    parfor i = 1:size(W,2)
%         Ri = RTcell{i};
        Ri = R(:, i)';
        Wi = W(:, i);
%         uList = find(R(:, i) > 0);
        uList = find(Ri >0);
        % A * P[i]' = b
        A = iFixedMatrix - wm * Q(uList,:)' * Q(uList,:) + Q(uList,:)' * diag(Wi(uList)) * Q(uList,:) + lambda * eye(n_factors);
        b = Q(uList,:)' * diag(Wi(uList)) * (Ri(uList)' - rm);
        P(i,:) = (A\b)';
    end
    
    cost = GetCost_baidu(R, Q, P, W, rm, lambda);
    fprintf('%d th iteration is complete , the cost is %f \n',iter,cost);
    costList(iter) = cost;
    
    
%     plot(1:iter,costList(1:iter),(iter+1):n_iterations,costList((iter+1):n_iterations));
%     title('cost after each epoch');
%     drawnow      
     
     
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