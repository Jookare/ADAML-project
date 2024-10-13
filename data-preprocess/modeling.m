%% ADAML - Project work
% Joona Kareinen
clc
close all 
clearvars
% Arguments for code
% engine_id: dataset to use (1-4)
% k_cv: k for k-fold cross-validation
% N_PLS: Number of LVs for PLS model

engine_id = 1;
k_cv = 5;
plot_flag = 1;

% Selected from the Q2 and RMSE plots of model_calibration
switch engine_id
    case 1
        N_PLS = 4;
    case 2
        N_PLS = 12;
    case 3
        N_PLS = 4;
    case 4
        N_PLS = 9;
end

% Load data and calibrate model. 
Data = data_pretreatment(engine_id);
model_calibration(Data, k_cv)
model_optimization(Data, N_PLS)

% model_evaluation(Data, N_PLS, plot_flag, 1)









%% Plot individual units


% individual_units(Data, N_PLS)
% Plots predictions for individual units
function individual_units(Data, N_PLS)
    kernel = 1;
    X_train = Data.Train(:,3:end);
    Y_train = Data.Train(:,2).^kernel;
    Y_train_mu = mean(Y_train);
    Y_train = Y_train;

    % Create a PLS model for the full train data
    [~,~,~,~, betaPLS] = plsregress(X_train, Y_train, N_PLS);
    
    % Apply the model to random units
    X_test = Data.Test(:,3:end);
    Y_test = Data.Test(:,2);
    
    
    N_units = max(Data.Test(:,1));
    figure();
    for k = 1:9
        subplot(3,3,k); hold on
        idx = randi(N_units);
        X = X_test(Data.Test(:,1) == idx, :);
        [rows, ~] = size(X);
        
        yfitPLS = [ones(rows,1) X]*betaPLS;
    
        plot(yfitPLS.^(1/kernel))
        plot(Y_test(Data.Test(:,1) == idx))
        title("Unit "+num2str(idx))
        xlabel("Time (cycles)");
        ylabel("RUL");
    end
    legend("Predicted RUL", "True RUL")
    sgtitle(Data.caseName)
end