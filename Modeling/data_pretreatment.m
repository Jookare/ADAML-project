function Data = data_pretreatment(engine_id, skewRUL)
% LOAD DATA - Loads and preprocesses data for the given engine id
    Data = struct();

    % Load data
    Train = readmatrix("data/train_FD00" + num2str(engine_id) + ".txt");
    Test = readmatrix("data/test_FD00" + num2str(engine_id) + ".txt");
    RUL = readmatrix("data/RUL_FD00" + num2str(engine_id) + ".txt");

    % Preprocess data
    [Train_out, Test_out, Vars] = data_preprocess(Train, Test, RUL,skewRUL);
    
    % Store in struct
    Data.TrainUnits = Train_out(:,1);
    Data.TrainCycles = Train_out(:,2);
    Data.Ytrain = Train_out(:, 3);
    Data.Xtrain = Train_out(:, 4:end);

    Data.TestUnits = Test_out(:,1);
    Data.TestCycles = Test_out(:,2);
    Data.Ytest = Test_out(:, 3);
    Data.Xtest = Test_out(:, 4:end);

    Data.caseName = strcat("FD\_00"+num2str(engine_id));
    Data.varNames = Vars;
    Data.skewer = skewRUL;

    % Take moving average of the X datas
    N_units = max( max(Data.TrainUnits), max(Data.TestUnits));
    for i = 1:N_units
        rows_train = (Data.TrainUnits == i);
        rows_test = (Data.TestUnits == i);
        Data.Xtrain(rows_train, :) = movmean(Data.Xtrain(rows_train, :), 7);
        Data.Xtest(rows_test, :) = movmean(Data.Xtest(rows_test, :), 7);
    end
end


function [Train, Test, Vars] = data_preprocess(Train, Test, RUL,skewRUL)
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
    RUL_train = compute_RUL(Train,[],skewRUL,0);
    RUL_test = compute_RUL(Test, RUL,skewRUL,1);
    
    % Add Unit and RUL to the array.
    Train_data = cat(2, Train(:,1), Train(:,2), RUL_train, X_train2);
    Test_data = cat(2, Test(:,1), Test(:,2), RUL_test, X_test2);
    
    % Return variables for each data
    Sensors = strings(1, 21);
    for i = 1:21
        Sensors(1, i) = ['Sensor ', num2str(i)];
    end
    
    % Find the Columns that are left
    vars = [Sensors(~train_mask)];
    
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


function RUL_col = compute_RUL(data, RUL, skew, testing)
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
        if testing==1
            max_rul = RUL(i) + length(cycles);
            rul = max_rul - cycles;
        else
            rul = max(cycles) - cycles;
    
        end
        rul = rul.^skew;
        % Update the second column of train_data with RUL for this unit
        RUL_col = cat(1, RUL_col, rul);
    end

end