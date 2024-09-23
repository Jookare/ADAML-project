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
% types = {'Train'};
num_datasets = length(Data);
num_types = length(types);

for k = 1:length(types)
    type = types{k};
    for i = 1:4
        subplot(num_types, num_datasets, (k-1)*num_datasets + i);
        % figure
        data = Data(i).(type).data;
        vars = Data(i).(type).vars;
    
        % Do not take Unit and Time into account here
        boxplot(data(:, 3:end), vars(3:end))
        title(type+" FD00"+num2str(i)+" (normalized)")
    end
end

%% Visualize the unit 50 of train
close all

data = Data(1).Train.data;
vars = Data(1).Train.vars;


unit = data(ismember(data(:, 1), 50), :);

% Do not plot the unit or RUL
plot(unit(:, 3:end))