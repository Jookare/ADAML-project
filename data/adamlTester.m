%% Project work ADAML - Lasse Johansson
% testing a predictive model for RUL's 
clc;
close all; 
clear all; 
colNames = {'RUL','OS1','OS2','OS3','Sen1','Sen2','Sen3','Sen4','Sen5','Sen6','Sen7','Sen8','Sen9','Sen10','Sen11','Sen12','Sen13','Sen14','Sen15','Sen16','Sen17','Sen18','Sen19','Sen20','Sen21'};%csvread('data/vars.csv');

%read data for case 1
X = csvread("data/FD004_RULedTest.csv");% select the case: 1 to 4.
Y = X(:,1)%RUL is here, which we predict.
%standardize the data
[X2, muX, stdX] = zscore(X);

for (i=1:9) %%remove columns for which the values is CONSTANT (redundant columns)
    [X2, colNames,stdX,muX] = constRem(X2,stdX, muX, colNames);
end

%do box-plot
boxplot(X2,'Labels',colNames);
%check covariance
cv = cov(X2);
figure();
surf(cv); hold on; title('Covariance matrix for variables');xlabel("Features");ylabel("Features");
% Principal Component Analysis (Note: not used for predictions at the
% moment)
[coeff,score,latent,tsquared,explained,mu] = pca(X2, 'Centered', false);
explVar = 100 * cumsum(latent)/ sum(latent);
% plot PCA
figure(); 
plot(1:length(explVar), explVar);
xlabel("No. PCs in the model");
ylabel("Explained variance of the model [R^2 value] [%]");
title("Cummulative explained variances by principal components");


%% Random Forest and making predictions
    [X2, colNames,stdX, muX] = varRem(1,X2, stdX, muX, colNames);% remove RUL that is Y from X.

% split data into training and validation data
X_train = [];
Y_train = [];
X_eval = [];
Y_eval = [];
evalSize = 0.3;%30% will be used as validation data
n = size(Y,1)
rands = rand(n,1);

trains =0;
evals =0;
for i=1:size(Y,1)
     if rands(i) > evalSize
        trains = trains+1; 
        X_train(trains,:) = X2(i,:);
        Y_train(trains) = Y(i);
     else
         evals = evals+1;
         X_eval(evals,:) = X2(i,:);
         Y_eval(evals) = Y(i);
     end    
end    
trains
evals
    %Ok, lets make RF model with the training data.
    numTrees = 10;
    T=fitcensemble(X_train,Y_train,'Method','Bag','NumLearningCycles',numTrees, ...%set method as bagging and and define tree count
    'Learners',templateTree('SplitCriterion','gdi'),...%Gini's diversity index
    'Options', statset('UseParallel',true))%parallel computing for SPEEEED

    preds = predict(T,X_eval);%make predictions with the validation data.
    figure();
    scatter(preds,Y_eval); hold on; xlabel("Testing data RUL");
    ylabel("Random Forest prediction RUL");

    %tree =fitctree(X,Y,'CrossVal', 'on')
    %showPredictorImportance(X2,Y,colNames);
    %view(tree.Trained{1},'Mode','graph')

%% remove data column with constant values (based on stdX)
function [X2, colNames,stdX, muX] = constRem(X2, stdX, muX, colNames)
  
   for (i =1:length(colNames))
       if (stdX(i)<0.000001)
           disp(strcat('removing ==>', colNames(i)));
           X2(:,i)=[];
           colNames(i) = [];
           stdX(i)=[];
           muX(i)=[];
           return;
       end    
   end
   
   disp('No removals');

    
end
%% remove the column at index i
function [X2, colNames,stdX, muX] = varRem(i,X2, stdX, muX, colNames)
       X2(:,i)=[];
       colNames(i) = [];
       stdX(i)=[];
       muX(i)=[];
  
end

%% utility function: show predictor importance
function [] = showPredictorImportance(X, Y,featnames)
    tree = fitctree(X,Y,'PredictorSelection','curvature',...
    'Surrogate','on');

    %Predictor importance
    imp = predictorImportance(tree);
    
    figure;
    bar(imp);
    title('Predictor Importance Estimates');
    ylabel('Estimates');
    xlabel('Predictors');
    h = gca;

    set(gca,'XTick',1:length(featnames))
    h.XTickLabel = featnames;
    h.XTickLabelRotation = 90;
    axis tight
    h.TickLabelInterpreter = 'none';
end
