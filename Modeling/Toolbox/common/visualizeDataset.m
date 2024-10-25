function visualizeDataset(model)

datasetName = model.datasetName;
noiseLevel  = model.noiseLevel;


%% For classification
if strcmp(datasetName, "synthetic-circles-classification")

    currentFile     = mfilename('fullpath');
    [pathstr, ~, ~] = fileparts(currentFile);
    paths           = fullfile(pathstr, '\datasets\synthetic');
    addpath(paths)
    load('data.mat');
    figure; hold on; box on;
    indexRed        = find(Y==1);
    indexBlue       = find(Y==2);
    indexGreen      = find(Y==3);
    indexMagenta    = find(Y==4);
    scatter(X(indexRed,1),      X(indexRed,2),     'ro');
    scatter(X(indexBlue,1),     X(indexBlue,2),    'b*');
    scatter(X(indexGreen,1),    X(indexGreen,2),   'g.');
    scatter(X(indexMagenta,1),  X(indexMagenta,2), 'mo');
    title("Synthetic dataset with four classes");
    xlabel("X1 synthetic variable");
    ylabel("X2 synthetic variable");


elseif strcmp(datasetName, "peaks-regression")
    [X1, X2]    = meshgrid(-2:0.1:2);
    X(:,1)      = X1(:);
    X(:,2)      = X2(:);
    Y           =  3*(1-X(:,1)).^2.*exp(-(X(:,1).^2) - (X(:,2)+1).^2) ...
        - 10*(X(:,1)/5 - X(:,1).^3 - X(:,2).^5).*exp(-X(:,1).^2-X(:,2).^2) ...
        - 1/3*exp(-(X(:,1)+1).^2 - X(:,2).^2);
    [row, col]  = size(X1);
    Y           = reshape(Y, row, col);

    subplot(2,3,1); % Original mapping surface
    surf(X1, X2, Y);
    title("Original mapping surface");
    xlabel("X_1")
    ylabel("X_2")
    zlabel("Y")

    subplot(2,3,2); % Surface with low noise
    [row, col]  = size(Y);
    noise1      = randn(row, col) * 0.05;
    Ynoisy1     = Y + noise1;
    surf(X1, X2, Ynoisy1);
    title("Surface with low noise (0.05)");
    xlabel("X_1")
    ylabel("X_2")
    zlabel("Ynoisy")

    subplot(2,3,3); % Surface with model noise
    noise       = randn(row, col) * noiseLevel;
    Ynoisy      = Y + noise;
    surf(X1, X2, Ynoisy);
    title("Surface with high noise " + string(noiseLevel));
    xlabel("X_1")
    ylabel("X_2")
    zlabel("Ynoisy")

    subplot(2,3,4); % Original mapping contour
    contour(X1, X2, Y);

    subplot(2,3,5); % Contour with low noise
    contour(X1, X2, Ynoisy1);

    subplot(2,3,6); % Contour with model noise
    contour(X1, X2, Ynoisy);

elseif strcmp(datasetName, "simple-quadratic-regression")
    [X1, X2] = meshgrid(-2:0.1:2);
    Y        = 1/2*X1.^2 +  X1.*X2 + X2.^2 + X2;
    figure;
    subplot(2,3,1); % Original mapping surface
    surf(X1, X2, Y);
    title("Original mapping surface");
    xlabel("X_1")
    ylabel("X_2")
    zlabel("Y")

    subplot(2,3,2); % Surface with low noise
    [row, col]  = size(Y);
    noise1      = randn(row, col) * 0.05;
    Ynoisy1     = Y + noise1;
    surf(X1, X2, Ynoisy1);
    title("Surface with low noise (0.05)");
    xlabel("X_1")
    ylabel("X_2")
    zlabel("Ynoisy")

    subplot(2,3,3); % Surface with model noise
    noise       = randn(row, col) * noiseLevel;
    Ynoisy      = Y + noise;
    surf(X1, X2, Ynoisy);
    title("Surface with high noise " + string(noiseLevel));
    xlabel("X_1")
    ylabel("X_2")
    zlabel("Ynoisy")

    subplot(2,3,4); % Original mapping contour
    contour(X1, X2, Y);

    subplot(2,3,5); % Contour with low noise
    contour(X1, X2, Ynoisy1);

    subplot(2,3,6); % Contour with model noise
    contour(X1, X2, Ynoisy);

end

end