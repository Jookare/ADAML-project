function Data = load_data(engine_id)
% LOAD DATA - Loads and preprocesses data for the given engine id
    Data = struct();

    % Load data
    Train = readmatrix("data/train_FD00" + num2str(engine_id) + ".txt");
    Test = readmatrix("data/test_FD00" + num2str(engine_id) + ".txt");
    RUL = readmatrix("data/RUL_FD00" + num2str(engine_id) + ".txt");

    % Preprocess data
    [Train_out, Test_out, Vars] = Data_preprocess(Train, Test, RUL);
    
    % Store in struct
    Data.Train = Train_out;
    Data.Test = Test_out;
    Data.caseName = "FD\_00"+num2str(engine_id);
    Data.varNames = Vars;
end


function [Train, Test, Vars] = Data_preprocess(Train, Test, RUL)
%DATA_PREPROCESS - preprocesses input data
%   This function takes in train and test data applies filtering and
%   normalization.
    
    % First five are not sensors so remove
    X_train = Train(:, 6:26);
    X_test  = Test(:, 6:26);
    
    % Normalize 
    [X_train, mu, sigma] = zscore(X_train);
    
    % Normalize the testing data with same mean and sigma
    X_test = normalize(X_test, 'center', mu, 'scale', sigma);
    
    % Find mask for NaN values or 0 std
    train_mask = create_mask(X_train);
    
    % Remove those variables
    X_train2 = X_train(:, ~train_mask);
    X_test2 = X_test(:, ~train_mask);
    
    % Computes the RUL for each measurement row
    RUL_train = compute_RUL(Train);
    RUL_test = compute_RUL(Test, RUL);
    
    % Add Unit and RUL to the array.
    Train_data = cat(2, Train(:,1), RUL_train, X_train2);
    Test_data = cat(2, Test(:,1), RUL_test, X_test2);
    
    % Return variables for each data
    Sensors = strings(1, 21);
    for i = 1:21
        Sensors(1, i) = ['Sensor ', num2str(i)];
    end
    
    % Find the Columns that are left
    vars = ['Unit', 'RUL', Sensors(~train_mask)];
    
    % Clear variables for struct
    clear Train Valid Test
    
    % Save the outputs to a struct
    Train = Train_data;
    Test = Test_data;
    Vars = vars;
end

function mask = create_mask(data)

    threshold = 1e-10;
    nan_mask = sum(isnan(data)) > 0;
    th_mask = std(data) < threshold;
    uniq_mask = zeros(1, size(data, 2));
    for i = 1:size(data, 2)
        uniq_mask(i) = length(unique(data(:, i))) < 10;
    end

    mask = nan_mask | th_mask | uniq_mask;
end


function RUL_col = compute_RUL(data, RUL)
% Creates the RUL for each measurement row. Can be given a vector that
% includes the RULs so that is used as the last RUL instead
    
    train_units = unique(data(:,1));
    RUL_col = [];
    
    for i = 1:length(train_units)
        unit_id = train_units(i);
        
        % Get the indices of rows corresponding to the current unit
        unit_idx = data(:,1) == unit_id;
        
        % Extract the cycles for the current unit
        cycles = data(unit_idx, 2);
        
        % Calculate the RUL: max(cycles) - current cycle
        if nargin == 2
            max_rul = RUL(i) + length(cycles);
            rul = max_rul - cycles;
        else
            rul = max(cycles) - cycles;
    
        end
        
        % Update the second column of train_data with RUL for this unit
        RUL_col = cat(1, RUL_col, rul);
    end

end