function [Data_low, Data_high] = split_data(Data,cycle_th)
%SPLIT_DATA splits the given data struct into two separate datasets based
%on the cycles
    
    Data_low = Data;
    Data_high = Data;
    
    % Separate low and high cycle data for training
    rows_low_train = Data.TrainCycles < cycle_th;
    rows_high_train = Data.TrainCycles >= cycle_th;
    
    % Separate low and high cycle data for testing
    rows_low_test = Data.TestCycles < cycle_th;
    rows_high_test = Data.TestCycles >= cycle_th;

    
    % Create separate datasets for low and high cycle models
    Data_low.Xtrain = Data.Xtrain(rows_low_train,:);
    Data_low.Ytrain = Data.Ytrain(rows_low_train,:);
    Data_low.Xtest = Data.Xtest(rows_low_test,:);
    Data_low.Ytest = Data.Ytest(rows_low_test,:);
    Data_low.TrainUnits = Data.TrainUnits(rows_low_test,:);
    Data_low.TestUnits  = Data.TestUnits (rows_low_test,:);
    
    Data_high.Xtrain = Data.Xtrain(rows_high_train,:);
    Data_high.Ytrain = Data.Ytrain(rows_high_train,:);
    Data_high.Xtest = Data.Xtest(rows_high_test,:);
    Data_high.Ytest = Data.Ytest(rows_high_test,:);
    Data_high.TrainUnits = Data.TrainUnits(rows_high_test,:);
    Data_high.TestUnits  = Data.TestUnits (rows_high_test,:);
end

