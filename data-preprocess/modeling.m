%% ADAML - Project work
% Joona Kareinen
clc
close all 
clearvars

% Arguments for code
% engine_id: dataset to use (1-4)
% k_cv: k for k-fold cross-validation
% show_plots: true/false flag for showing plots
% N_PLS: Number of LVs for PLS model

engine_id = 2;
k_cv = 5;
show_plots = true;

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
model_calibration(Data, k_cv, show_plots);

[scoresVIP, indexVip] = model_optimization(Data, N_PLS, show_plots);

% Data.Train(:, [false; false; scoresVIP >= 1]) = [];
% Data.Test(:, [false; false; scoresVIP >= 1]) = [];
% Data.varNames(:, [false; false; scoresVIP >= 1]) = [];

model_evaluation(Data, N_PLS, show_plots);
% 

%% Plot individual units
% Chooses 9 random units from given datasets and shows the time-series
% style RUL prediction

individual_units(Data, N_PLS)
% Plots predictions for individual units
function individual_units(Data, N_PLS)
    X_train = Data.Train(:,3:end);
    Y_train = Data.Train(:,2);
    Y_train_mu = mean(Y_train);
    Y_train = Y_train - Y_train_mu;

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
        
        yfitPLS = [ones(rows,1) X]*betaPLS + Y_train_mu;
    
        plot(yfitPLS)
        plot(Y_test(Data.Test(:,1) == idx))
        title("Unit "+num2str(idx))
        xlabel("Time (cycles)");
        ylabel("RUL");
    end
    legend("Predicted RUL", "True RUL")
    sgtitle(Data.caseName)
end