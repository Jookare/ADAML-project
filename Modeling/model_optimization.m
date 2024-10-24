function Data = model_optimization(Data, N_PLS, show_plots, VIP_th)
%MODEL_OPTIMIZATION - Computes VIP scores for all variables
%   Returns the VIP score
    
    % Initialize the data
    stopIteration = false;
    while ~stopIteration
    
        X_train = Data.Train(:,3:end);
        Y_train = Data.Train(:,2);
        Y_train_mu = mean(Y_train);
        Y_train = Y_train - Y_train_mu;
        varNames = Data.varNames(3:end);

        [vipScore, betaPLS] = compute_VIP(X_train, Y_train, N_PLS, VIP_th, varNames, show_plots);
        lowVIP = vipScore < VIP_th;
        lowBeta = abs(betaPLS) < 1;

        Data.Train(:, [false; false; lowVIP]) = [];
        Data.Test(:, [false; false; lowVIP]) = [];
        Data.varNames(:, [false; false; lowVIP]) = [];
        
        Data.Train(:, [false; false; lowBeta]) = [];
        Data.Test(:, [false; false; lowBeta]) = [];
        Data.varNames(:, [false; false; lowBeta]) = [];
        
        if sum(lowVIP) == 0 && sum(lowBeta) == 0
            stopIteration = true;
        else
            pause(1)
        end
    end
    
    
end



function [vipScore, betas] = compute_VIP(X_train, Y_train, N_PLS, VIP_th, varNames, show_plots)

    % PLS regression
    [P, Q, T, ~, betaPLS, ~, ~, stats] = plsregress(X_train, Y_train, N_PLS);

    % Compute VIP scores
    W0 = stats.W ./ sqrt(sum(stats.W.^2,1));
    p              = size(P, 1);
    sumSq          = sum(T.^2,1).*sum(Q.^2,1);
    vipScore       = sqrt(p* sum(sumSq.*(W0.^2),2) ./ sum(sumSq,2));   

    % No constant term used
    betas = betaPLS(2:end);

    % Show plots
    if show_plots
        figure(13)
        cla
        subplot(1,2,1)

        % Plot PLS coefficients
        b =bar(betas);
        legend("PLS Regression Coefficients");
        xticklabels(varNames);
        
        % Plot VIP scores with thresholds
        goodVIP = (vipScore >= 1);
        badVIP = (vipScore < VIP_th);

        subplot(1,2,2)
        vipScore
        scatter(1:length(vipScore),vipScore, 50, 'o', 'filled', MarkerFaceColor="#EDB120")
        hold on
        scatter(find(goodVIP),vipScore(goodVIP),50, 'o', 'filled', MarkerFaceColor="#0072BD")
        scatter(find(badVIP),vipScore(badVIP),50, 'o', 'filled', MarkerFaceColor="#D95319")
        plot([1 length(vipScore)],[1 1],'--k')
        xlabel('Predictor Variables')
        ylabel('VIP Scores')
        legend("Okay VIP", "Good VIP", "Bad VIP")
        xticks(1:length(vipScore))
        xticklabels(varNames);
        ylim([0 2.5])
    end
end