% ADAML - Project work
% Joona Kareinen
%%
clc
close all 
clearvars

Data = {};
for engine_id = 1:4
    data = load_data(engine_id);
    Data(engine_id).Train = data.Train;
    Data(engine_id).Test = data.Test;
    Data(engine_id).varNames = data.varNames;
end
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
        data = Data(i).(type);
        vars = Data(i).varNames;
    
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
    data = Data(i).(type);
    vars = Data(i).varNames;
        
    % Do not take Unit and Time into account here
    boxplot(data(:, 3:end), vars(3:end))
    title(type+" FD00"+num2str(i)+" (normalized)")
end
%% Analyze the sensors with very low variance
close all
engine_id = 3;
vars = Data(engine_id).varNames;
data = Data(engine_id).(type);
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