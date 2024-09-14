% ADAML - Project work
% Joona Kareinen
%%
clc
close all 
clearvars

% Dataset FD001
Train = readmatrix("data/train_FD001.txt");
Test = readmatrix("data/test_FD001.txt");
RUL = readmatrix("data/RUL_FD001.txt");

% Create a vectors for the variable names
Sensors = strings(1, 21);
for i = 1:21
    Sensors(1, i) = ['Sensor ', num2str(i)];
end
Vars = ['Unit', 'Time', 'OS1', 'OS2', 'OS3', Sensors];

% Take only the sensor data
Train = Train(:,6:26);
Test =  Test(:, 6:26);
Vars =  Vars(:, 6:26);

Train_norm  = (Train - mean(Train))./(std(Train));
boxplot(Train_norm, Sensors)
title("Train FD001 (normalized)")

%% Add the unit and the time
Data2(:,1) = Data(:,1);
Data2(:,2) = Data(:,2);

% From the plot Sensors9 and 14 seem suspicious
% Index = 2 + 9 = 11
figure; hold on
plot(Data2(:, 9), '.r')
plot(Data2(:, 11), '.g')
plot(Data2(:, 16), '.b')
legend("Sensor 7", "Sensor 9", "Sensor 14")

%% Test data
RUL_min = min(RUL);
idx_rul = find(RUL == RUL_min);
idx_rul = 31
Data = Test(Test(:,1) == idx_rul, :);

figure
subplot(1,2,1)
boxplot(Data, Vars)
title("Test FD001 Unit"+ num2str(idx_rul)+ " (unnormalized)")

subplot(1,2,2)
Data2 = (Data - mean(Data))./(std(Data));
boxplot(Data2, Vars)
title("Test FD001 Unit"+ num2str(idx_rul)+ " (normalized)")


Data2(:,1) = Data(:,1);
Data2(:,2) = Data(:,2);
% From the plot Sensors9 and 14 seem suspicious
% Index = 2 + 9 = 11
figure; hold on
x = 1:size(Data, 1);
RUL_y = (size(Data, 1)-1+RUL_min):-1:RUL_min;

plot(x, RUL_y/max(RUL_y), 'b')

plot(Data2(:, 9), '.r')
plot(Data2(:, 11), '.g')
plot(Data2(:, 16), '.b')

% legend show
legend("RUL (at the end 8)", "Sensor 7", "Sensor 9", "Sensor 14")

% line()

%%
A1 = readmatrix("RUL_FD001.txt");
A2 = readmatrix("RUL_FD002.txt");
A3 = readmatrix("RUL_FD003.txt");
A4 = readmatrix("RUL_FD004.txt");


B1 = readmatrix("train_FD001.txt");
B2 = readmatrix("train_FD002.txt");
B3 = readmatrix("train_FD003.txt");
B4 = readmatrix("train_FD004.txt");

C1 = readmatrix("test_FD001.txt");
C2 = readmatrix("test_FD002.txt");
C3 = readmatrix("test_FD003.txt");
C4 = readmatrix("test_FD004.txt");

disp("Train Test")
disp([max(B1(:,1)), max(C1(:,1))])
disp([max(B2(:,1)), max(C2(:,1))])
disp([max(B3(:,1)), max(C3(:,1))])
disp([max(B4(:,1)), max(C4(:,1))])
