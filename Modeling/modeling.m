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

engine_id = 3;
k_cv = 5;
show_plots = true;

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

engine_id = 1;
k_cv = 5;
show_plots = true;

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
model_calibration(Data, k_cv, show_plots);

% Optimize model (Remove unnecessary variables)
Data = model_optimization(Data, N_PLS, k_cv, show_plots, VIP_th);

model = {};
model.datasetName = "RUL";
model.initialParam = [2, -1];
model.nsamp        = 1;
model.learnRate    = 0.1;
model.regrType     = 2; % 1 to be used in classification, 2 for regression, 3 PCR 
model.iter         = 100;
model.center       = 1;
model.params       = exp(model.initialParam);
model.plot         = 1;
model.sp           = 0.5;
model.kernelType   = "gaussian";
model.classification = 0;
model.momentum     = 1; % 1 works better with few parameters, 2 works better with many parameters
model.family       = 0; 
model.redPredict   = 0;
model.Err = [];


model = KPLS_model_optimization(Data, N_PLS, model);