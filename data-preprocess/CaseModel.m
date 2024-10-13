%% ADAML - Project work
% This scripts trains a PLS model for the defined case number
% Lasse Johansson (edited version of Joona's work)

clc; clear all; close all;

i =1;%select case
k_cv =5;
N_PLS = 4;%choose number of LV's
Data = load(i);
doCV(Data, k_cv);
trainModel(Data, N_PLS);
%biplot(Data);

%% load data for the ase
function [Data] = load_data(i) 
  % Load all data to a cell array for easy manipulation
   Data = struct();
   Train = readmatrix("data/train_FD00" + num2str(i) + ".txt");
   Test = readmatrix("data/test_FD00" + num2str(i) + ".txt");
   RUL = readmatrix("data/RUL_FD00" + num2str(i) + ".txt");
   % Preprocess data
   [Train_out, Test_out] = Data_preprocess(Train, Test, RUL);
   % Store in structure
   Data.Train = Train_out;
   Data.Test = Test_out;
   Data.caseName = "FD\_00"+num2str(i);
   Data.varNames = Data.Train.vars(3:end);% TODO: what are the first two columns? Time and case?
end

%% CV
function [] = doCV(Data, k_cv) 
    train_data = Data.Train.data;% Get the training data
    N_units = max(train_data(:, 1)); % Find how many units
    cv = cvpartition(N_units, 'KFold', k_cv); % initialize k-fold cross-validation

    % For each j gets a Calib and Valid data
    for j = 1:k_cv
        [calib, valid] = cross_validation(train_data, cv, j);
        % Get the variables and the RUL
        X_calib = calib(:, 3:end);
        Y_calib = calib(:,2);
    
        X_valid = valid(:, 3:end);
        Y_valid = valid(:,2);
    
        [rows, ~] = size(X_valid);
        % Total Sum of Squares 
        TSS = sum((Y_calib - mean(Y_calib)).^2);
    
        % Find the number of variables
        N_vars = length(Data.Train.vars(3:end));

        for k = 1:N_vars
            [~,~,~,~, betaPLS] = plsregress(X_calib, Y_calib, k);
            % Fit to the validation data
            yfitPLS = [ones(rows,1) X_valid]*betaPLS;

            % Predicted Error Sum of Squares (PRESS)
            PLS_press(j,k) = sum((Y_valid - yfitPLS).^2);
    
            % Root Mean Squared Error (RMSE)
            PLS_rmse(j, k) = sqrt(PLS_press(j, k) / length(Y_valid));
    
            % Q²
            PLS_Q2(j, k) = 1 - PLS_press(j, k)/TSS;
        end % for vars
    end % for k_cv

    % Plot some statistics
    Q2_CV_PLS = mean(PLS_Q2);
    RMSE_CV_PLS = mean(PLS_rmse);
    
    figure();
    subplot(1,2,1);
    plot(Q2_CV_PLS);  xlabel("Latent Variables");title(Data.caseName);ylabel("Q^2_{CV}")
    subplot(1,2,2);
    plot(RMSE_CV_PLS);xlabel("Latent Variables");title(Data.caseName);ylabel("RMSE_{CV}")
end

%% Barplot to analyze the variables
function[] = trainModel(Data, N_PLS)
    X_train = Data.Train.data(:,3:end);
    Y_train = Data.Train.data(:,2);
    Y_train_mu = mean(Y_train);
    Y_train = Y_train - Y_train_mu;
    % Create a PLS model for the full train data
    [~,~,~,~, betaPLS_final] = plsregress(X_train, Y_train, N_PLS);
    betas = [betaPLS_final(1:end)];%why drop the first out?
    figure();
    bar(betas);legend("PLS Regression Coefficients");xticklabels(Data.varNames);

   
    X_test = Data.Test.data(:,3:end);
    Y_test = Data.Test.data(:,2);
    [rows, ~] = size(X_test);
    yfitPLS = [ones(rows,1) X_test]*betas + Y_train_mu;
    % yfitPLS = [X_test]*betas;
    figure();
    scatter(Y_test, yfitPLS); hold on; title(Data.caseName);
    axis equal
    xlabel("True RUL testing value");
    ylabel("PLS prediction");
end

%% biplot
function[] = biplot(Data)
    X_train = Data.Train.data(:,3:end);
    Y_train = Data.Train.data(:,2);
    [P, Q, T, U, betaPLS, varPLS, mse, stats] = plsregress(X_train, Y_train, 2);

    P = P ./ sqrt(sum(P.^2));
    Q = Q ./ sqrt(sum(Q.^2));
    T = T ./ sqrt(sum(T.^2));

    figure();
    Data.varNames
    %TODO this gives an error!
    biplot([P; Q], 'Scores', T, 'VarLabels', Data.varNames);
    xlabel("Latent Variable 1");
    ylabel("Latent Variable 2");

end




