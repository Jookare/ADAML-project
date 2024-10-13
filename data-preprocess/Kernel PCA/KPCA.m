function Beta_KPLS = KPLS(X, Y, N, kernel)
    
    
    K = kernel.computeMatrix(X, X);
    nl = length(X(:,1));
    oneN = ones(nl, nl)/nl;

    K = K - oneN*K - K*oneN + oneN*K*oneN;

    W, P, Q = KSIMPLS(K, Y, N);

    Beta_KPLS = W*(P'*W)^(-1)*Q';
end

function [W, P, Q] = KSIMPLS(X, Y, N)
    
    C = Y'*X;
    for i = 1:N
        % Loadings
        w = pca(C);
        t = X*w;
        q = Y'*t/(t'*t);
        u = Y*q/(q'*q);
        p = X'*t/(t'*t);
        
        % Store t, p, q, u, w
        T = t; 
        P = p;
        Q = q;
        U = u;
        W = w;
        C = C - P*(P'*P)^(-1)*P'*C;
    end

end