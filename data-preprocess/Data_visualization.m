% ADAML - Project work
% Joona Kareinen
%%
clc
close all 
clearvars

% Load all data to a cell array for easy manipulation
Data = struct();

for i = 1:4
    Train = readmatrix("data/train_FD00" + num2str(i) + ".txt");
    Test = readmatrix("data/test_FD00" + num2str(i) + ".txt");
    RUL = readmatrix("data/RUL_FD00" + num2str(i) + ".txt");

    % Preprocess data
    [Train_out, Valid_out, Test_out] = Data_preprocess(Train, Test, RUL);
    
    % Store in structure
    Data(i).Train = Train_out;
    Data(i).Valid = Valid_out;
    Data(i).Test = Test_out;
end

% Remove unncessary variables
clear Train Test RUL Train_out Valid_out Test_out i

%% Visualize train, valid and test data in 3 by 4 grid for easy comparison
figure;
types = {'Train', 'Valid', 'Test'};
num_datasets = length(Data);
num_types = length(types);

for k = 1:3
    type = types{k};
    for i = 1:4
        subplot(num_types, num_datasets, (k-1)*num_datasets + i);
        data = Data(i).(type).data;
        vars = Data(i).(type).vars;
    
        % Do not take Unit and Time into account here
        boxplot(data(:, 3:end), vars(3:end))
        title(type+" FD00"+num2str(i)+" (normalized)")
    end
end
