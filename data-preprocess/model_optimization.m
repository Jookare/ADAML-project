function [scoresVIP, indexVip] = model_optimization(Data, N_PLS, show_plots)
%MODEL_OPTIMIZATION - Computes VIP scores for all variables
%   Returns the VIP score
    X_train = Data.Train(:,3:end);
    Y_train = Data.Train(:,2);
    Y_train_mu = mean(Y_train);
    Y_train = Y_train - Y_train_mu;
    
    [P, Q, T, U, betaPLS, varPLS, mse, stats] = plsregress(X_train, Y_train, N_PLS);
       

    W0 = stats.W ./ sqrt(sum(stats.W.^2,1));
    p              = size(P, 1);
    sumSq          = sum(T.^2,1).*sum(Q.^2,1);
    vipScore       = sqrt(p* sum(sumSq.*(W0.^2),2) ./ sum(sumSq,2));

    [scoresVIP, indexVip] = sort(vipScore, "descend");

    if show_plots
        figure();
        bar(betaPLS(2:end));
        legend("PLS Regression Coefficients");
        xticklabels(Data.varNames(3:end));

        indVIP         = find(vipScore >= 1);
        figure
        scatter(1:length(vipScore),vipScore, 50, 'o', 'filled')
        hold on
        scatter(indVIP,vipScore(indVIP),50, 'o', 'filled')
        plot([1 length(vipScore)],[1 1],'--k')
        xlabel('Predictor Variables')
        ylabel('VIP Scores')
        xticks(1:length(vipScore))
        xticklabels(Data.varNames(3:end));
        ylim([0 2.5])
    end
end

