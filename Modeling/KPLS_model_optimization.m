function model = KPLS_model_optimization(Data, N_PLS, model, optimize)
%MODEL_OPTIMIZATION Summary of this function goes here
%   Detailed explanation goes here

    S =30;
 
    model.dim = N_PLS;
    model.X = Data.Xtrain(1:S:end, :);
    model.Y = Data.Ytrain(1:S:end);
    model.muY = mean(model.Y);
    model.Y = model.Y - model.muY;
    
    % Apply the model to a test data
    model.Xtest = Data.Xtest(1:end, :);
    model.Ytest = Data.Ytest(1:end);
    
    model       = predict(model);
    model.ypred = model.ypred + model.muY;
    model.initialParams = model.params;
    model.Err(end+1) = rmse(model.ypred, model.Ytest);

    if model.plot % this initial plot is unnecessary
        %model = plotResults(model);
        %title("Initial model")
    end
    
    if optimize
        tic
        model = optimizeParams(model);
        toc
    
        if model.plot
            figure;
    
            model.paramName = ["Kernel Width", "Regularization", "2nd Width", "2nd Scaler"];
            L = length(model.bestparam);
    
            % Define line width and color
            lineWidth = 1;
            Color = [253, 63, 146]./255; % Approximation of fuchsia
    
            nexttile;
            plot(abs(model.runningLoss), 'LineWidth', lineWidth, 'Color', Color);
            title('Moving mean (5 iter) for loss');
    
            nexttile;
            plot(model.history(1).rhoHist, 'LineWidth', lineWidth, 'Color', Color);
            title('Original loss');
    
            for i = 1:L
                nexttile;
                plot(model.history(i).paraHist, 'LineWidth', lineWidth, 'Color', Color);
                title("\theta" + string(i));
    
                nexttile;
                plot(model.history(i).grad_muHist, 'LineWidth', lineWidth, 'Color', Color);
                title("\nabla_{\rho} " + string(i));
            end
        end
        model.params       = exp(model.bestparam);
        model.finalParams  = model.params;
        model              = predict(model);
        model.ypred = model.ypred + model.muY;
        model.Err(end+1)  = rmse(model.ypred, model.Ytest);
    
        if model.plot
            model = plotResults(model);
            title("Final k-PLS model - "+ Data.caseName )
        end
    end
end

