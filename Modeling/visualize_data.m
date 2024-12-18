% ADAML - Project work
% Joona Kareinen
%%
clc
close all 
clearvars

Data = {};
for engine_id = 1:4
    data = data_pretreatment(engine_id, 1);
    Data{engine_id} = data;
end

%% Visualize train and test data in 2 by 4 grid for easy comparison
figure;
num_datasets = length(Data);

for i = 1:4
    subplot(2, num_datasets, i);
    % figure
    data = Data{i}.Xtrain;
    vars = Data{i}.varNames;

    % Do not take Unit and Time into account here
    boxplot(data, vars)
    title("Train FD00"+num2str(i)+" (normalized)")

    subplot(2, num_datasets, i + 4);
    data = Data{i}.Xtest;

    % Do not take Unit and Time into account here
    boxplot(data, vars)
    title("Test FD00"+num2str(i)+" (normalized)")
end
%% Plot same thing separately
close all
type = 'Train';

for i = 1:4
    figure
    data = Data{i}.Xtrain;
    vars = Data{i}.varNames;
        
    % Do not take Unit and Time into account here
    boxplot(data(:, 3:end), vars(3:end))
    title(type+" FD00"+num2str(i)+" (normalized)")
end
%% Analyze the sensors with very low variance
close all
engine_id = 3;
vars = Data{engine_id}.varNames;
data = Data{engine_id}.Xtrain;
idx = vars == "Sensor 7";

figure; hold on
unit_i = Data{engine_id}.TrainUnits == 10;
plot(data(unit_i, idx))

%% Visualize raw data for report
close all
data1 = readmatrix("data/train_FD001.txt");
data2 = readmatrix("data/train_FD002.txt");


data1 = data1(data1(:,1) == 50, 1:end);
data1 = zscore(data1);
data2 = data2(data2(:,1) == 50, 1:end);
data2 = zscore(data2);

norm_data1 = movmean(data1, 7);
norm_data2 = movmean(data2, 7);

% plot few sensors
for k = [1, 7, 9]
    figure; hold on
    plot(data1(:, k+5))
    plot(norm_data1(:, k+5))
    if k == 1
        ylim([-1.5 2])
    elseif k == 9
        ylim([-2 3.5])
    end
    xlabel("Time (cycles)")
    ylabel("measurement")
    xlim([0, 222])
    legend("Raw data", "Moving mean (7)", 'Location','northwest')

    figure; hold on
    plot(data2(:, k+5))
    plot(norm_data2(:, k+5))
    if k == 7
        ylim([-3 3])
    elseif k == 9
        ylim([-2 3.5])
    end
    xlabel("Time (cycles)")
    ylabel("measurement")
    xlim([0, 222])
    legend("Raw data", "Moving mean (7)", 'Location','northwest')
end

%% Visualize (normalized) raw data
close all
Sensors = strings(1, 21);
for i = 1:21
    Sensors(1, i) = ['Sensor ', num2str(i)];
end

% Find the Columns that are left
vars = ['Unit', 'Time', 'OS1', 'OS2', 'OS3', Sensors];
    
for k = 1:4
    % Load data
    Train = readmatrix("data/train_FD00" + num2str(k) + ".txt");
    Test = readmatrix("data/test_FD00" + num2str(k) + ".txt");
    
    data = zscore(Train);
    figure
    boxplot(data, vars);
    title("train\_FD00" + num2str(k))
end

%% Plot Q² and RMSE 
clc
close all
clearvars

k_cv = 5;
for engine_id = 1:4
    switch engine_id
        case 1
            N_PLS = 2;
            VIP_th = 0.95;
            skewRUL = 0.3;
            kPLS_optimize = true;
        case 2
            N_PLS = 6; 
            VIP_th = 0.6;
            skewRUL = 0.4;
            kPLS_optimize = true;
        case 3
            N_PLS = 3;
            VIP_th = 0.6;
            skewRUL = 0.4;
            kPLS_optimize = true;%this is not that good for FD003 but let's test it at least.
        case 4
            N_PLS = 5;
            VIP_th = 0.6;
            skewRUL = 1;
            kPLS_optimize = true;% use k-PLS for this tricky case.
    end
    Data = data_pretreatment(engine_id, 1);
    Data = model_optimization(Data, N_PLS, k_cv, 0, VIP_th);
    
    [Q2_CV_PLS, RMSE_CV_PLS] = model_calibration(Data, k_cv, 0);
    
    subplot(2,4, engine_id)
    plot(Q2_CV_PLS)
    xlabel("Latent Variables")
    xticks([0 5 10 15])
    title("FD00"+num2str(engine_id))
    if engine_id == 1
        ylabel("Q²_{CV}")
    end

    subplot(2,4, engine_id + 4)
    plot(RMSE_CV_PLS)
    xlabel("Latent Variables")
    xticks([0 5 10 15])
    % xticklabels({})

    if engine_id == 1
        ylabel("RMSE_{CV}")
    end
end
% print('-dpdf','Test_plot.pdf','-bestfit','-r200')


%% Visualize the individual unit predictions


% Chooses 9 random units from given datasets and shows the time-series
% style RUL prediction
engine_id = 3;
k_cv = 5;
show_plots = true;

% Selected from the Q2 and RMSE plots of model_calibration
switch engine_id
    case 1
        N_PLS = 4;
    case 2
        N_PLS = 7; % Quite large now that I think about it.
    case 3
        N_PLS = 4;
    case 4
        N_PLS = 9;
end

% Load data and calibrate model. 
Data = data_pretreatment(engine_id);

individual_units(Data, N_PLS)
% Plots predictions for individual units
function individual_units(Data, N_PLS)
    X_train = Data.Xtrain;
    Y_train = Data.Ytrain;
    Y_train_mu = mean(Y_train);
    Y_train = Y_train - Y_train_mu;

    % Create a PLS model for the full train data
    [~,~,~,~, betaPLS] = plsregress(X_train, Y_train, N_PLS);
    
    % Apply the model to random units
    X_test = Data.Xtest;
    Y_test = Data.Ytest;
    
    N_units = max(Data.TestUnits);
    figure();
    for k = 1:9
        subplot(3,3,k); hold on
        idx = randi(N_units);
        X = X_test(Data.TestUnits == idx, :);
        [rows, ~] = size(X);
        
        yfitPLS = [ones(rows,1) X]*betaPLS + Y_train_mu;
    
        plot(yfitPLS)
        plot(Y_test(Data.TestUnits == idx))
        title("Unit "+num2str(idx))
        xlabel("Time (cycles)");
        ylabel("RUL");
    end
    legend("Predicted RUL", "True RUL")
    sgtitle(Data.caseName)
end

%% For different models based on cycles

