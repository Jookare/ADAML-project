function model = plotResults(model)

if strcmp(model.datasetName, "synthetic-circles-classification")
    yhat        = model.ypred;
    [row, col]  = size(yhat);
    yhat2       = zeros(row, col);
    for i = 1:row
        [~, j]      = max(yhat(i,:));
        yhat2(i,j)  = 1;
    end
    yhat = yhat2;

    classes = categories(categorical(model.YCodeT));
    decoded = onehotdecode(yhat, classes,2);
    if model.plot == 1
        figure;
        confusionchart(decoded, categorical(model.YCodeT));
    end
    decoded = double(decoded);
    if model.plot == 1
        figure; hold on; box on;
        indexRed        = find(decoded==1);
        indexBlue       = find(decoded==2);
        indexGreen      = find(decoded==3);
        indexMagenta    = find(decoded==4);
    scatter(model.Xtest(indexRed,1), model.Xtest(indexRed,2), 'o', ...
        'MarkerEdgeColor',[0.85,0.33,0.10], 'MarkerFaceColor', [0.91,0.67,0.56]);
    scatter(model.Xtest(indexBlue,1), model.Xtest(indexBlue,2), 'o', ...
        'MarkerEdgeColor',[0.00,0.45,0.74], 'MarkerFaceColor', [0.56,0.91,0.87]);
    scatter(model.Xtest(indexGreen,1), model.Xtest(indexGreen,2), 'o', ...
        'MarkerEdgeColor',[0.47,0.67,0.19], 'MarkerFaceColor', [0.60,0.91,0.56]);
    scatter(model.Xtest(indexMagenta,1), model.Xtest(indexMagenta,2), 'o', ...
        'MarkerEdgeColor', [0.64,0.08,0.18], 'MarkerFaceColor', [0.99,0.51,0.51]);
        title("Synthetic dataset prediction with four classes - PLS-DA");
        xlabel("x_1");
        ylabel("x_2");
    end
    model.accuracy = sum(decoded == model.YCodeT) / numel(decoded);

elseif strcmp(model.datasetName, "covid") || strcmp(model.datasetName, "hyperspectral") || strcmp(model.datasetName, "cancer") || strcmp(model.datasetName, "BeesandMites") || strcmp(model.datasetName, "Flow")
    yhat        = model.ypred;
    [row, col]  = size(yhat);
    yhat2       = zeros(row, col);
    for i = 1:row
        [~, j]      = max(yhat(i,:));
        yhat2(i,j)  = 1;
    end
    yhat = yhat2;

    classes = categories(categorical(model.YCodeT));
    decoded = onehotdecode(yhat, classes,2);
    if model.plot == 1
        figure;
        confusionchart(decoded, categorical(model.YCodeT));
    end
    decoded = double(decoded);
    model.accuracy = sum(decoded == double(model.YCodeT)) / numel(decoded);
elseif strcmp(model.datasetName, "NASA")
    figure()
    c = abs(model.Ytest - model.ypred);
    scatter(model.Ytest, model.ypred, 50, c, '.'); 
    colorbar
    axis equal
    xlabel("True RUL testing value");
    ylabel("PLS prediction");
else

    figure;
    scatter(model.ypred, model.Ytest);
    hold on 
    plot(model.Ytest, model.Ytest);
    xlabel("Predicted Y");
    ylabel("True Y");
end

end