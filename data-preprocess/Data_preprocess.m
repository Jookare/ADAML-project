function [Train, Valid, Test] = Data_preprocess(Train, Test, RUL)
%DATA_PREPROCESS Takes data as input and preprocesses the data
%   Detailed explanation goes here

% Take 20% randomly from Train as validation
num_units = max(Train(:, 1));
num_valid = floor(num_units*0.2);
valid_idx = randperm(num_units, num_valid);
valid_data = Train(ismember(Train(:, 1), valid_idx), :);
train_data = Train(~ismember(Train(:, 1), valid_idx), :);

% First five are not sensors so normalize the sensor data
X_train = train_data(:, 6:26);
X_valid = valid_data(:, 6:26);
X_test  = Test(:, 6:26);

[X_train, mu, sigma] = zscore(X_train);

% Normalize the validation and testing data with same mean and sigma
X_valid = normalize(X_valid, 'center', mu, 'scale', sigma);
X_test = normalize(X_test, 'center', mu, 'scale', sigma);

% Find mask for NaN values or 0 std
train_mask = create_mask(X_train);
valid_mask = create_mask(X_valid);
test_mask = create_mask(X_test);

% Remove those variables
X_train2 = X_train(:, ~train_mask);
X_valid2 = X_valid(:, ~valid_mask);
X_test2 = X_test(:, ~test_mask);

% Computes the RUL for each measurement row
RUL_train = compute_RUL(train_data);
RUL_valid = compute_RUL(valid_data);
RUL_test = compute_RUL(Test, RUL);

% Add Unit and RUL to the array.
Train_data = cat(2, train_data(:,1), RUL_train, X_train2);
Valid_data = cat(2, valid_data(:,1), RUL_valid, X_valid2);
Test_data = cat(2, Test(:,1), RUL_test, X_test2);

% Return variables for each data
Sensors = strings(1, 21);
for i = 1:21
    Sensors(1, i) = ['Sensor ', num2str(i)];
end

% Find the Columns that are left
Train_vars = ['Unit', 'RUL', Sensors(~train_mask)];
Valid_vars = ['Unit', 'RUL', Sensors(~valid_mask)];
Test_vars = ['Unit', 'RUL', Sensors(~test_mask)];

% Clear variables for struct
clear Train Valid Test

% Save the outputs to a struct
Train.data = Train_data;
Train.vars = Train_vars;

Valid.data = Valid_data;
Valid.vars = Valid_vars;

Test.data = Test_data;
Test.vars = Test_vars;
end

function mask = create_mask(data)

    threshold = 1e-10;
    nan_mask = sum(isnan(data)) > 0;
    th_mask = std(data) < threshold;

    mask = nan_mask | th_mask;
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