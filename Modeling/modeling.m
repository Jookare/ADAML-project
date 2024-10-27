%% ADAML - Project work
% Joona Kareinen
% PLS - Partial Least Squares
clc
close all 
clearvars

% Arguments for code
% engine_id: dataset to use (1-4)
% k_cv: k for k-fold cross-validation
% show_plots: true/false flag for showing plots
% N_PLS: Number of LVs for PLS model

engine_id = 2;
k_cv = 5;
show_plots = true;
cycle_th = 150;

% Selected from the Q2 and RMSE plots of model_calibration AFTER model_optimization
switch engine_id
    case 1
        N_PLS = 2;
        VIP_th = 0.75;
    case 2
        N_PLS = 6; 
        VIP_th = 0.5;
    case 3
        N_PLS = 4;
        VIP_th = 0.9;
    case 4
        N_PLS = 8;
        VIP_th = 0.5;
end

% Load data
Data = data_pretreatment(engine_id);

% Run model calibration
model_calibration(Data, k_cv, show_plots);

% Optimize model (Remove unnecessary variables)
Data = model_optimization(Data, N_PLS, k_cv, show_plots, VIP_th);

% Check calibration again
model_calibration(Data, k_cv, show_plots);

% Evaluate with test data
model_evaluation(Data, N_PLS, show_plots);


%% Kernel PLS (initialized by: AK)
clc
close all
clearvars

engine_id = 2;
k_cv = 5;
show_plots = true;
cycle_th = 100;


% Selected from the Q2 and RMSE plots of model_calibration
switch engine_id
    case 1
        N_PLS = 2;
        VIP_th = 0.75;
    case 2
        N_PLS = 6; 
        VIP_th = 0.5;
    case 3
        N_PLS = 4;
        VIP_th = 0.9;
    case 4
        N_PLS = 8;
        VIP_th = 0.5;
end


% Load data and calibrate model. 
Data = data_pretreatment(engine_id);

% [Data_low, Data_high] = split_data(Data, cycle_th);
% Data = Data_high;

model_calibration(Data, k_cv, show_plots);

% Optimize model (Remove unnecessary variables)
Data = model_optimization(Data, N_PLS, k_cv, show_plots, VIP_th);

best_loss = 123;
best_params = [];
for i = 1:10
    model = {};
    model.datasetName = "NASA";
    model.initialParam = -5 + 10*rand(1,10);
    model.nsamp        = 1;
    model.learnRate    = 0.4;
    model.regrType     = 2; % 1 to be used in classification, 2 for regression, 3 PCR 
    model.iter         = 50;
    model.center       = 1;
    model.params       = exp(model.initialParam);
    model.plot         = 1;
    model.sp           = 0.5;
    
    % gaussian, matern1/2, matern3/2, matern5/2, cauchy
    kernels = ["gaussian", "matern1/2", "matern3/2", "matern5/2", "cauchy"];
    model.kernelType   = "matern3/2";
    model.classification = 0;
    model.momentum     = 1; % 1 works better with few parameters, 2 works better with many parameters
    model.family       = 1; 
    model.redPredict   = 0;
    model.Err = [];
    
    optimize = true;
    
    model = KPLS_model_optimization(Data, N_PLS, model, optimize);
    if model.Err(end) < best_loss
        best_loss = model.Err(end);
        best_params = model.finalParams;
    end
end
best_loss
best_params

%%
% Engine 2: matern5/2
% Engine 3: 0.1401    0.1639   34.7183    0.0219   12.7704    0.1365    4.4878    0.0427    0.9158    2.4963

