function [X_final, Vars_final] = Data_preprocess(X)
%DATA_PREPROCESS Takes data as input and preprocesses the data
%   Takes data as input and normalizes it to 0 mean and 1 std

Sensors = strings(1, 21);
for i = 1:21
    Sensors(1, i) = ['Sensor ', num2str(i)];
end
% No preprocessing yet
X_final = X;
Vars_final = ['Unit', 'Time', 'OS1', 'OS2', 'OS3', Sensors];

% Take only the sensor data
% X2 = X(:, 6:26);
% mu = mean(X2);
% sig = std(X2);
% 
% % Check if sigma is very small 
% sig_chk = sig < 1e-10;
% 
% X_norm  = (X2 - mu)./(sig);
% 
% % Take only the rows that have not 0 standard deviation
% % Add the unit and time back it for convenience
% X_final = X_norm(:, ~sig_chk);
% 
% X_final = cat(2, X(:,1), X_final);
% X_final = cat(2, X(:,2), X_final);
% 
% % Find the Columns that are left
% Vars_final = ['Unit', 'Time', Sensors(~sig_chk)];
end

