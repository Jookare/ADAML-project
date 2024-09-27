function [Calib, Valid] = cross_validation(Train, cv, i)
%CROSS_VALIDATION - function that takes in the Train dataset, cvpartition
%and i to define the cv number. Returns Calibration and Validation
%datasets.

    units = unique(Train(:, 1));

    % Get the indices for training and validation sets
    idx_calib = training(cv, i);
    idx_valid = test(cv, i);

    % Get the units corresponding to these indices
    calib_units = units(idx_calib);
    valid_units = units(idx_valid);

    % Find rows in Train that correspond to calibration and validation units
    Calib = Train(ismember(Train(:, 1), calib_units), :);
    Valid = Train(ismember(Train(:, 1), valid_units), :);
end

