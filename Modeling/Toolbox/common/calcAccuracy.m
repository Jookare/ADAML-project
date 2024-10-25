function accuracy = calcAccuracy(model)


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
    decoded = double(decoded);
    accuracy = sum(decoded == double(model.YCodeT)) / numel(decoded);
    
end