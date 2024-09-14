% ADAML - Project work
% Joona Kareinen
%%
clc
close all 
clearvars

% Load all data to a cell array for easy manipulation
train_data = cell(2,4);
test_data = cell(2,4);
RUL_data = cell(1,4);
for i = 1:4
    Train = readmatrix("data/train_FD00"+num2str(i)+".txt");
    Test = readmatrix("data/test_FD00"+num2str(i)+".txt");
    RUL = readmatrix("data/RUL_FD00"+num2str(i)+".txt");
    % Train
    [Train, Vars_final] = Data_preprocess(Train);
    train_data{1, i} = Train;
    train_data{2, i} = Vars_final;
    
    % Test
    [Test, Vars_final] = Data_preprocess(Test);
    test_data{1, i} = Test;
    test_data{2, i} = Vars_final;

    % RUL
    RUL_data{i} = RUL;
end
% Remove unncessary variables
clear Train Test RUL Vars_final i

%% Visualize training data
close all
for i = 1:4
    figure
    data = test_data{1, i};
    vars = test_data{2, i};

    % Do not take Unit and Time into account here
    boxplot(data(:, 3:end), vars(3:end))
    title("Train FD00"+num2str(i)+" (normalized)")
end

%% Visualize testing data
close all
for i = 1:4
    figure
    data = test_data{1, i};
    vars = test_data{2, i};

    % Do not take Unit and Time into account here
    boxplot(data(:, 3:end), vars(3:end))
    title("Test FD00"+num2str(i)+" (normalized)")
end

