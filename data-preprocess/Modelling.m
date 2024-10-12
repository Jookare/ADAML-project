% ADAML - Project work
% Joona Kareinen
%%
clc
close all 
clearvars

% Load all data to a cell array for easy manipulation
Data = struct();

for i = 1:4
    Train = readmatrix("data/train_FD00" + num2str(i) + ".txt");
    Test = readmatrix("data/test_FD00" + num2str(i) + ".txt");
    RUL = readmatrix("data/RUL_FD00" + num2str(i) + ".txt");

    % Preprocess data
    [Train_out, Test_out] = Data_preprocess(Train, Test, RUL);
    
    % Store in structure
    Data(i).Train = Train_out;
    Data(i).Test = Test_out;
end

% Remove unncessary variables
clear Train Test RUL Train_out Valid_out Test_out i


%%
clc; %close all

% Define variables
N_models = 4;
k_cv = 5;

for i = 1:N_models
    % Get the training data
    train_data = Data(i).Train.data;
    
    % Find how many units
    N_units = max(train_data(:, 1));
    
    % initialize k-fold cross-validation
    cv = cvpartition(N_units, 'KFold', k_cv);

    % For each j gets a Calib and Valid data
    for j = 1:k_cv

        [calib, valid] = cross_validation(train_data, cv, j);
        
        % Get the variables and the RUL
        X_calib = calib(:, 3:end);
        Y_calib = calib(:,2);
    
        X_valid = valid(:, 3:end);
        Y_valid = valid(:,2);
    
        % Compute PCA
        [P, T, latent] = pca(X_calib, 'Centered', false, 'Economy', false);
        
        [rows, ~] = size(X_valid);
    
        % Total Sum of Squares 
        TSS = sum((Y_calib - mean(Y_calib)).^2);
    
        % Find the number of variables
        N_vars = length(Data(i).Train.vars(3:end));
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
    
        end

    end

    % Plot some statistics
    Q2_CV_PLS = mean(PLS_Q2);
    
    PRESS_CV_PLS = mean(PLS_press);
    
    RMSE_CV_PLS = mean(PLS_rmse);
    
    figure;
    plot(Q2_CV_PLS);
    xlabel("Latent Variables")
    title("FD\_00"+num2str(i))
    ylabel("Q^2_{CV}")
    figure;
    plot(RMSE_CV_PLS);
    xlabel("Latent Variables")
    title("FD\_00"+num2str(i))
    ylabel("RMSE_{CV}")
    clear PLS_Q2 PLS_press PLS_rmse
end



%% Barplot to analyze the variables
%close all

% Chosen 
N_PLS = 8; % Could be 2 as well
idx = 4;

vars = Data(idx).Train.vars(3:end);
X_train = Data(idx).Train.data(:,3:end);
Y_train = Data(idx).Train.data(:,2);

% Create a PLS model for the full train data
[~,~,~,~, betaPLS_final] = plsregress(X_train, Y_train, N_PLS);

figure;
betas = [betaPLS_final(2:end)];
bar(betas);
legend("PLS Regression Coefficients");
xticklabels(vars);

%%

[P, Q, T, U, betaPLS, varPLS, mse, stats] = plsregress(X_train, Y_train, 2);

P = P ./ sqrt(sum(P.^2));

Q = Q ./ sqrt(sum(Q.^2));

T = T ./ sqrt(sum(T.^2));
figure;
vars
b = biplot([P; Q], 'Scores', T, 'VarLabels', vars);
xlabel("Latent Variable 1");
ylabel("Latent Variable 2");