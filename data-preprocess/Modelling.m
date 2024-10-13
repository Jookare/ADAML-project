%% ADAML - Project work
% Joona Kareinen
clc
close all 
clearvars

% Arguments for code
% engine_id: dataset to use (1-4)
% k_cv: k for k-fold cross-validation
% N_PLS: Number of LVs for PLS model

k_cv = 5;

% Engine 1
engine_id = 1;

Data = load_data(engine_id);
calibrate_model(Data, k_cv)
N_PLS = 4;
train_model(Data, N_PLS)





% Train_model function
function train_model(Data, N_PLS)
    X_train = Data.Train(:,3:end);
    kernel = 1;

    Y_train = Data.Train(:,2).^kernel;
    Y_train_mu = mean(Y_train);
    Y_train = Y_train - Y_train_mu;

    % Create a PLS model for the full train data, contant term not needed
    [~,~,~,~, betaPLS] = plsregress(X_train, Y_train, N_PLS);
    
    % Create barplot of the coefficients
    figure();
    bar(betaPLS(2:end));
    legend("PLS Regression Coefficients");
    xticklabels(Data.varNames(3:end));
    
    % Apply the model to a test data
    X_test = Data.Test(:,3:end);
    Y_test = Data.Test(:,2);
    [rows, ~] = size(X_test);
    yfitPLS = [ones(rows,1) X_test]*betaPLS + Y_train_mu;

    figure(); hold on
    scatter(Y_test, yfitPLS.^(1/kernel)); 
    title(Data.caseName);
    axis equal
    xlabel("True RUL testing value");
    ylabel("PLS prediction");
    plot(Y_test, Y_test)

    % Compute absolut error in RULS

end

