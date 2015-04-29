% newfinalrun

% new run file to save the drunken electrodes

% clean things
clear all;
clc;
close all;


%% final weights/models/predictor variables to be saved %%
% save the final accuracies
pho_lin = cell(3,1);
pho_svm = cell(3,1);
pho_lasso = cell(3,1);

% final predictions are stored in this
predicted_dg_lin = cell(3,1);
predicted_dg_svm = cell(3,1);
predicted_dg_lasso = cell(3,1);

svmmodel = cell(3,5);

%% Set what models are gonna be used for this run %%

%
% ONLY VARIABLE TO WORRY ABOUT :)
%
% always set recalculate feats unless you run this same file back to back
recalculatefeats = 1;
%
%

% set 1 if you'd want to plot
doplot = 0;

% set 1 if you'd want to use only linearreg
dolinearreg = 1;

% set 1 if you'd want to use only svr
dosvr = 0;

% set 1 if you'd want to use only lasso
dolasso = 0;

%
% CV SHOULD ONLY BE 0 IN THIS FILE
%
cv = 0;

% ratio of cross validation
ratio = 0.95;


%% Define the configuration to get the R matrix from the raw EEG
% window length in milliseconds
config.('window') = 100;
% number of history bits used : n-1 past and current
config.('history') = 3;
% overlap time in milliseconds
config.('noverlap') = 50;
% total 1024 points
config.('nfft') = 1024;
% freqbands used
config.('freqbands') = [5 15; 20 25; 75 115; 125 160; 160 175];
config.('fs') = 1000;


%% Get all the data from the portal %%
% don't redownload if the data already exists
getData('shanjitsingh', 'login,bin');


%% Visualize the data %%

% plot the test and train datasets for each patient in a 3x1 plot using
% subplots

if doplot==1
    
    load('train_data_1');
    load('train_labels_1');
    figure(1)
    subplot(2,1,1);
    plot(train_data_1);
    
    subplot(2,1,2);
    plot(train_labels_1);
    
    
    load('train_data_2');
    load('train_labels_2');
    figure(2)
    subplot(2,1,1);
    plot(train_data_2);
    
    subplot(2,1,2);
    plot(train_labels_2);
    
    
    load('train_data_3');
    load('train_labels_3');
    figure(3)
    subplot(2,1,1);
    plot(train_data_3);
    subplot(2,1,2);
    plot(train_labels_3);
    
    clearvars train_data_* train_labels_*
end


%% Step 3: Get all the Features
% todo:
% 1. Put more features in getFeatures.m
% 2. Do feature selection on x_train_<patient_no> - draw graphs here!


% note that CV = 0 for this file always

% get and save all the features
if recalculatefeats
    disp('Recalculating all the features');
    
    shuffleindices = randperm(310000);
    [x_train_1, y_train_1, x_test_1, y_test_1] = getFeatures(config, 1, shuffleindices, cv, ratio);
    save('x_train_1.mat','x_train_1','y_train_1');
    save('x_test_1.mat', 'x_test_1', 'y_test_1');
    
    [x_train_2, y_train_2, x_test_2, y_test_2] = getFeatures(config, 2, shuffleindices, cv, ratio);
    save('x_train_2.mat','x_train_2','y_train_2');
    save('x_test_2.mat', 'x_test_2', 'y_test_2');
    
    [x_train_3, y_train_3, x_test_3, y_test_3] = getFeatures(config, 3, shuffleindices, cv, ratio);
    save('x_train_3.mat','x_train_3','y_train_3');
    save('x_test_3.mat', 'x_test_3', 'y_test_3');
    
    
    
else
    disp('Not recalculating features.');
    
end
clearvars x_train_1 y_train_1 x_train_2 y_train_2 x_train_3 y_train_3 x_test_1 x_test_2 x_test_3 recalculateFeatures y_test_1 y_test_2 y_test_3;


%% Use the saved features to make models
disp('Doing predictions now');
% At this point, there are x_train, y_train variables saved in
% x_train_<patient_no> and x_test, y_test variables saved in
% y_test_<patient_no>





% number of predictions
numpredictions = 147500;

if dolinearreg
    disp('Doing prediction via linear regression');
    for patient = 1:3
        % linear regression
        load('weight_linreg');
        [predicted_dg_lin{patient},pho_lin{patient}] =  getLinPredictions(config,linweights{patient},patient,numpredictions);
    end
    
    %
    % change after you make other models
    %
    predicted_dg = predicted_dg_lin;
end

if dosvr
    for patient = 1:3
        % SVR
        for finger = 1:5
            [svmmodel{patient}{finger}, a, b] = svm(config, patient, finger, 1,  numpredictions);
            predicted_dg_svm{patient}(1:numpredictions,finger) = a;
            pho_svm{patient}(1,finger) = b;
        end
        
    end
    
    % prediction values or whatever
end


% collect individual phos and get the final pho
%     tempmean = [mean(cell2mat(pho{1})) mean(cell2mat(pho{2})) mean(cell2mat(pho{3}))];
%     corr = mean(tempmean);



% cv = 2 -> getting the training error when trained on complete data and
% testing on complete data

save('predicted_dg.mat', 'predicted_dg');
