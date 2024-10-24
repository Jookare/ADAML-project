function [Q2_CV_PLS, RMSE_CV_PLS] = model_calibration(Data, k_cv, show_plots) 

    N_units = max(Data.TrainUnits); % Find how many units
    cv = cvpartition(N_units, 'KFold', k_cv); % initialize k-fold cross-validation

    % Find the number of variables
    N_vars = length(Data.varNames);
    
    % Initialize metric arrays
    PLS_press = zeros(k_cv, N_vars);
    PLS_rmse = zeros(k_cv, N_vars);
    PLS_Q2 = zeros(k_cv, N_vars);

    % For each j gets a Calib and Valid data
    for j = 1:k_cv
        [Calib, Valid] = cross_validation(Data, cv, j);

        % Get the variables and the RUL
        [X_calib, mu, sigma] = zscore(Calib.X);

        Y_calib_mu = mean(Calib.Y);
        Y_calib = Calib.Y - Y_calib_mu;

        X_valid = normalize(Valid.X, 'center', mu, 'scale', sigma);
        Y_valid = Valid.Y;

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


function [Calib, Valid] = cross_validation(Data, cv, i)
%CROSS_VALIDATION - function that takes in the Train dataset, cvpartition
% and i to define the cv number. Returns Calibration and Validation
% datasets.

    units = unique(Data.TrainUnits);

    % Get the indices for training and validation sets
    idx_calib = training(cv, i);
    idx_valid = test(cv, i);

    % Get the units corresponding to these indices
    calib_units = units(idx_calib);
    valid_units = units(idx_valid);

    % Find rows in Train that correspond to calibration and validation units
    calib_rows = ismember(Data.TrainUnits, calib_units);
    valid_rows = ismember(Data.TrainUnits, valid_units);
    
    % Construct Calib and Valid datas
    Calib.X = Data.Xtrain(calib_rows,:);
    Calib.Y = Data.Ytrain(calib_rows);

    Valid.X = Data.Xtrain(valid_rows,:);
    Valid.Y = Data.Ytrain(valid_rows);

end

