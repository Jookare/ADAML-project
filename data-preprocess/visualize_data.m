% ADAML - Project work
% Joona Kareinen
%%
clc
close all 
clearvars

Data = {};
for engine_id = 1:4
    data = data_pretreatment(engine_id);
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
data1 = readmatrix("data/train_FD001.txt");
data2 = readmatrix("data/train_FD002.txt");


data1 = data1(data1(:,1) == 50, 1:end);
data1 = zscore(data1);
data2 = data2(data2(:,1) == 50, 1:end);
data2 = zscore(data2);

% plot few sensors
for k = [1, 7, 9]
    figure
    plot(data1(:, k+5))
    if k == 1
        ylim([-1.5 2])
    elseif k == 9
        ylim([-2 3.5])
    end
    xlabel("Time (cycles)")
    ylabel("measurement")
    xlim([0, 222])
    figure
    plot(data2(:, k+5))
    if k == 7
        ylim([-3 3])
    elseif k == 9
        ylim([-2 3.5])

    end
    xlabel("Time (cycles)")
    ylabel("measurement")
    xlim([0, 222])
end

%% Visualize (normalized) raw data
close all
Sensors = strings(1, 21);
for i = 1:21
    Sensors(1, i) = ['Sensor ', num2str(i)];
end

% Find the Columns that are left
vars = ['Unit', 'Time', 'OS1', 'OS2', 'OS3', Sensors];
    
for k = 1:4
    % Load data
    Train = readmatrix("data/train_FD00" + num2str(k) + ".txt");
    Test = readmatrix("data/test_FD00" + num2str(k) + ".txt");
    
    data = zscore(Train);
    figure
    boxplot(data, vars);
    title("train\_FD00" + num2str(k))
end

%%
close all
data = Data(2).Train;


plot(data(:,3), data(:,4), '.')