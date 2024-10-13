function model_optimization(Data, N_PLS)
%MODEL_OPTIMIZATION Summary of this function goes here
%   Detailed explanation goes here

    X_train = Data.Train(:,3:end);
    Y_train = Data.Train(:,2);
    Y_train_mu = mean(Y_train);
    Y_train = Y_train - Y_train_mu;

    % Create a PLS model for the full train data
    [P, Q, T, U, betaPLS, varPLS, mse, stats] = plsregress(X_train, Y_train, N_PLS);
   
    % Apply the model to a test data
    X_test = Data.Test(:,3:end);
    Y_test = Data.Test(:,2);
    [rows, ~] = size(X_test);

    yfitPLS = [ones(rows,1) X_test]*betaPLS;

    W0 = stats.W ./ sqrt(sum(stats.W.^2,1));
    p              = size(P, 1);
    sumSq          = sum(T.^2,1).*sum(Q.^2,1);
    vipScore       = sqrt(p* sum(sumSq.*(W0.^2),2) ./ sum(sumSq,2));
    indVIP         = find(vipScore >= 1);
    
    figure
    scatter(1:length(vipScore),vipScore,'o', 'filled')
    hold on
    scatter(indVIP,vipScore(indVIP),'o', 'filled')
    plot([1 length(vipScore)],[1 1],'--k')
    xlabel('Predictor Variables')
    ylabel('VIP Scores')
    xticks(1:length(vipScore))
    xticklabels(Data.varNames(3:end));
end

