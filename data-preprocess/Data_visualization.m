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
    [Train_out, Test_out] = Data_preprocess(Train, Test, RUL);
    
    % Store in structure
    Data(i).Train = Train_out;
    Data(i).Test = Test_out;
end

% Remove unncessary variables
% clear Train Test RUL Train_out Valid_out Test_out i

%% Visualize train and test data in 2 by 4 grid for easy comparison
figure;
types = {'Train', 'Test'};
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
%% Plot same thing separately
close all
type = 'Train';

for i = 1:4
    figure
    data = Data(i).(type).data;
    vars = Data(i).(type).vars;
        
    % Do not take Unit and Time into account here
    boxplot(data(:, 3:end), vars(3:end))
    title(type+" FD00"+num2str(i)+" (normalized)")
end
%% Analyze the sensors with very low variance
close all
vars = Data(3).(type).vars;
data = Data(3).(type).data;
idx = vars == "Sensor 13";

figure; hold on
unit_i = data(:,1) == 10;
plot(data(unit_i, idx))

%% Visualize raw data for report
close all
Train = readmatrix("data/train_FD004.txt");


% Take data for unit 50
data = Train(Train(:,1) == 50, 6:end);
% plot few sensors
for k = [1, 7, 9]
    figure
    plot(data(:, k))
    xlabel("Time (cycles)")
    ylabel("measurement")
end