function Data = model_optimization(Data, N_PLS, k_cv, show_plots, VIP_th)
%MODEL_OPTIMIZATION - Computes VIP scores for all variables
%   Returns the VIP score
    
    disp("Optimizing model parameters...")
    % Initialize the data
    stopIteration = false;

    [Q2_orig, RMSE_orig] = model_calibration(Data, k_cv, 0);
    var = 0;
    while ~stopIteration
    
        X_train = Data.Xtrain;
        Y_train = Data.Ytrain;
        Y_train_mu = mean(Y_train);
        Y_train = Y_train - Y_train_mu;
        varNames = Data.varNames;

        [vipScore, betaPLS] = compute_VIP(X_train, Y_train, N_PLS, VIP_th, varNames, show_plots);
        
        [Data, stopFlag] = remove_variables(Data,vipScore, betaPLS, VIP_th);
        var = var + size(X_train, 2) - size(Data.Xtrain,2);

        if stopFlag
            stopIteration = true;
            [Q2_new, RMSE_new] = model_calibration(Data, k_cv, 0);    
            fprintf('\n')
            disp("Optimization finished.")
            disp(num2str(var)+" variables removed")

            disp("Q2 score: "+num2str(round(Q2_orig(N_PLS), 4)) + " => "+num2str(round(Q2_new(N_PLS), 4)))
            disp("RMSE score: "+num2str(round(RMSE_orig(N_PLS),2)) + " => "+num2str(round(RMSE_new(N_PLS), 2)))

        else
            % pause(1)
        end
    end
    compute_VIP(Data.Xtrain, Data.Ytrain, N_PLS, VIP_th, Data.varNames, show_plots);
    
end

function [Data, stopFlag] = remove_variables(Data, vipScore, betaPLS, VIP_th)
    [sorted_VIP, idx_VIP] = sort(vipScore);
    [sorted_B, idx_B] = sort(abs(betaPLS));
    lowVIP = sorted_VIP < VIP_th;
    %lowBeta = abs(betaPLS) < 1;
    
    % Remove the variable with the lowest score
    if sorted_VIP(1) < VIP_th
        disp("Removing variable '" + Data.varNames(idx_VIP(1))+ "' due to low VIP score")
        Data.Xtrain(:, idx_VIP(1)) = [];
        Data.Xtest(:, idx_VIP(1)) = [];
        Data.varNames(idx_VIP(1)) = [];
    elseif sorted_B(1) < 1.5 && false % This is dangerous?
        disp("Removing variable '" + Data.varNames(idx_B(1))+ "' due to low regression coefficient")
        Data.Xtrain(:, idx_B(1)) = [];
        Data.Xtest(:, idx_B(1)) = [];
        Data.varNames(idx_B(1)) = [];
    end
    
    stopFlag = sum(lowVIP) == 0;% && sum(lowBeta) == 0;
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
        bar(betas);
        %title(Data.caseName);
        legend("PLS Regression Coefficients");
        xticklabels(varNames);
        
        % Plot VIP scores with thresholds
        goodVIP = (vipScore >= 1);
        badVIP = (vipScore < VIP_th);

        subplot(1,2,2)
        scatter(1:length(vipScore),vipScore, 50, 'o', 'filled', MarkerFaceColor="#EDB120")
        hold on
        %title(Data.caseName);
        scatter(find(goodVIP),vipScore(goodVIP),50, 'o', 'filled', MarkerFaceColor="#0072BD")
        scatter(find(badVIP),vipScore(badVIP),50, 'o', 'filled', MarkerFaceColor="#D95319")
        plot([1 length(vipScore)],[1 1],'--k')
        xlabel('Predictor Variables')
        ylabel('VIP Scores')
        legend("Okay VIP", "Good VIP", "Bad VIP")
        xticks(1:length(varNames))
        xticklabels(varNames);
        ylim([0 2.5])
    end
end