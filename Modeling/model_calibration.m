function [Q2_CV_PLS, RMSE_CV_PLS] = model_calibration(Data, k_cv, show_plots) 

    train_data = Data.Train; % Get the training data
    N_units = max(train_data(:, 1)); % Find how many units
    cv = cvpartition(N_units, 'KFold', k_cv); % initialize k-fold cross-validation

    % Find the number of variables
    N_vars = length(Data.varNames(3:end));
    
    % Initialize metric arrays
    PLS_press = zeros(k_cv, N_vars);
    PLS_rmse = zeros(k_cv, N_vars);
    PLS_Q2 = zeros(k_cv, N_vars);

    % For each j gets a Calib and Valid data
    for j = 1:k_cv
        [calib, valid] = cross_validation(train_data, cv, j);
        % Get the variables and the RUL
        X_calib = calib(:, 3:end);
        [X_calib, mu, sigma] = zscore(X_calib);

        Y_calib_mu = mean(calib(:,2));
        Y_calib = calib(:,2) - Y_calib_mu;
        X_valid = valid(:, 3:end);
        X_valid = normalize(X_valid, 'center', mu, 'scale', sigma);
        Y_valid = valid(:,2);

        [rows, ~] = size(X_valid);

        % Total Sum of Squares 
        TSS = sum((Y_calib - mean(Y_calib)).^2);

        for k = 1:N_vars
            [~, ~, ~, ~, betaPLS] = plsregress(X_calib, Y_calib, k);
            % Fit to the validation data
            yfitPLS = [ones(rows,1) X_valid]*betaPLS +  Y_calib_mu;

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
    
    if show_plots
        figure();
        subplot(1,2,1)
        plot(Q2_CV_PLS); 
        title(Data.caseName);
        xlabel("Latent Variables");
        ylabel("Q^2_{CV}")

        subplot(1, 2, 2);
        plot(RMSE_CV_PLS);
        title(Data.caseName);
        xlabel("Latent Variables");
        ylabel("RMSE_{CV}")
    end
end


function [Calib, Valid] = cross_validation(Train, cv, i)
%CROSS_VALIDATION - function that takes in the Train dataset, cvpartition
% and i to define the cv number. Returns Calibration and Validation
% datasets.

    units = unique(Train(:, 1));

    % Get the indices for training and validation sets
    idx_calib = training(cv, i);
    idx_valid = test(cv, i);

    % Get the units corresponding to these indices
    calib_units = units(idx_calib);
    valid_units = units(idx_valid);

    % Find rows in Train that correspond to calibration and validation units
    Calib = Train(ismember(Train(:, 1), calib_units), :);
    Valid = Train(ismember(Train(:, 1), valid_units), :);
end

