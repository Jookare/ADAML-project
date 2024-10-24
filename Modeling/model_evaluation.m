% Train_model function
function model_evaluation(Data, N_PLS, show_plots)
    X_train = Data.Xtrain;
    Y_train = Data.Ytrain;
    Y_train_mu = mean(Y_train);
    Y_train = Y_train - Y_train_mu;



    % Create a PLS model for the full train data
    [~,~,~,~, betaPLS] = plsregress(X_train, Y_train, N_PLS);
        
    % Apply the model to a test data
    X_test = Data.Xtest;
    Y_test = Data.Ytest;
    [rows, ~] = size(X_test);

    yfitPLS = [ones(rows,1) X_test]*betaPLS + Y_train_mu;
    
    if show_plots
        % Barplot of the coefficients
        figure();
        bar(betaPLS(2:end));
        legend("PLS Regression Coefficients");
        xticklabels(Data.varNames);
        
        % RUL plot
        figure()
        c = abs(Y_test - yfitPLS);
        scatter(Y_test, yfitPLS, 50, c, '.'); 
        colorbar
        title(Data.caseName);
        axis equal
        xlabel("True RUL testing value");
        ylabel("PLS prediction");

        % Residual plot
        figure()
        scatter(Y_test, c, 50, c, '.');
        ylabel("Residual")
        xlabel("True RUL testing value")
        
    end

    % Compute TSS
    TSS = sum((Y_train - mean(Y_train)).^2);

    % Predicted Error Sum of Squares (PRESS)
    PLS_press = sum((Y_test - yfitPLS).^2);

    % Root Mean Squared Error (RMSE)
    PLS_rmse = sqrt(PLS_press / length(Y_test));

    % Q²
    PLS_Q2 = 1 - PLS_press/TSS;
    fprintf("\nModel evaluation results:\n")
    disp("Q2:")
    disp(PLS_Q2)

    disp("RMSE:")
    disp(PLS_rmse)


end