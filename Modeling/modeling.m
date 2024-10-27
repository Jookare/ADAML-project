%% ADAML - Project work
% Joona Kareinen & co
% PLS - Partial Least Squares
clc
close all 
clearvars

%add Toolbox to path.
currentFile     = matlab.desktop.editor.getActiveFilename;
[pathstr, ~, ~] = fileparts(currentFile);
paths           = fullfile(pathstr, 'Toolbox/common');
addpath(paths)


% Arguments for code
% engine_id: dataset to use (1-4)
% k_cv: k for k-fold cross-validation
% show_plots: true/false flag for showing plots
% N_PLS: Number of LVs for PLS model

engine_id = 3;
k_cv = 5;
show_plots = true;
skewRUL = 1;% poorman's effort to skew all RUL-values nonlinearly (e.g., 0.5 => sqrt(x).
kPLS_optimize =false;
% Selected from the Q2 and RMSE plots of model_calibration AFTER model_optimization
switch engine_id
    case 1
        N_PLS = 2;
        VIP_th = 0.95;
        skewRUL = 0.3;
        kPLS_optimize = true;
    case 2
        N_PLS = 5; 
        VIP_th = 0.6;
        skewRUL = 0.4;
        kPLS_optimize = true;
    case 3
        N_PLS = 4;
        VIP_th = 0.9;
        skewRUL = 0.4;
        kPLS_optimize = true;%this is not that good for FD003 but let's test it at least.
    case 4
        N_PLS = 5;
        VIP_th = 0.6;
        skewRUL = 0.4;
        kPLS_optimize = true;% use k-PLS for this tricky case.
end

% Load data
Data = data_pretreatment(engine_id, skewRUL);
% Run model calibration
model_calibration(Data, k_cv, 0);

% Optimize model (Remove unnecessary variables)
Data = model_optimization(Data, N_PLS, k_cv, show_plots, VIP_th);

% Check calibration again
model_calibration(Data, k_cv, show_plots);

% Evaluate with test data
model_evaluation(Data, N_PLS, show_plots);


%% Kernel PLS (initialized by: AK)
if (kPLS_optimize)
    show_plots = false;
    %Load data again without skew and make no images.
    Data = data_pretreatment(engine_id, 1);
    % Run model calibration
    model_calibration(Data, k_cv, 0);
    % Optimize model (Remove unnecessary variables)
    Data = model_optimization(Data, N_PLS, k_cv, show_plots, VIP_th);
    
    % Check calibration again
    model_calibration(Data, k_cv, show_plots);
    
    % Evaluate with test data
    model_evaluation(Data, N_PLS, show_plots);

    model = {};
    model.datasetName = "NASA";
    model.initialParam = [1,1];
    model.nsamp        = 1;
    model.learnRate    = 0.15;
    model.regrType     = 2; % 1 to be used in classification, 2 for regression, 3 PCR 
    model.iter         = 100;
    model.center       = 1;
    model.params       = exp(model.initialParam);
    model.plot         = 1;
    model.sp           = 0.5;
    
    % gaussian, matern1/2, matern3/2, matern5/2, cauchy
    kernels = ["gaussian", "matern1/2", "matern3/2", "matern5/2", "cauchy"];
    model.kernelType   = "matern5/2";
    model.classification = 0;
    model.momentum     = 2; % 1 works better with few parameters, 2 works better with many parameters
    model.family       = 0; 
    model.redPredict   = 0;
    model.Err = [];
    
    model = KPLS_model_optimization(Data, N_PLS, model, kPLS_optimize);
    model.finalParams
    model.Err(end)
end

%%
% Engine 2: matern5/2
% Engine 3: 0.1401    0.1639   34.7183    0.0219   12.7704    0.1365    4.4878    0.0427    0.9158    2.4963

