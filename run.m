% run this script to make predictions

% clean the workspace
clear all;
clc;
close all;


recalculateFeatures = 1;
doplot = 0;
dolinearreg = 1;
dosvr = 1;
dolasso = 0;

% cv can take 0,1,2
% cv = 0 -> training on complete data and testing on test data

% cv = 1 -> when training on some parts of training data and testing on
% unseen parts of the testing data

% cv = 2 -> getting the training error when trained on complete data and
% testing on complete data

cv = 0;
ratio = 0.95;

%% Step 1: Get all the data %%
getData;


%% Step 1.2: Visualize the data %%

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


%% Step 2: Define configuration
% Define configuration for the regressors used
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

% save the final accuracies
pho_lin = cell(3,1);
pho_svm = cell(3,1);
pho_lasso = cell(3,1);

% final predictions are stored in this
predicted_dg_lin = cell(3,1);
predicted_dg_svm = cell(3,1);
predicted_dg_lasso = cell(3,1);


svmmodel = cell(3,5);

%% Step 3: Get all the Features
% todo:
% 1. Put more features in getFeatures.m
% 2. Do feature selection on x_train_<patient_no> - draw graphs here!

if recalculateFeatures
    disp('Recalculating all the features');
    
    %
    % Include more features in getFeatures.m
    %
    %
    %
    
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
    
    
    
    %
    % Do feature selection using PCA or whatever
    %
    %
    %
    
    % save the final features in three files
    % note saving when the files exist overwrite the file
    
    
else
    disp('Not recalculating features.');
    
    tl = load('x_train_1');
    x_train_1 = tl.('x_train_1');
    
    
    tl = load('x_train_2');
    x_train_2 = tl.('x_train_2');
    
    
    tl = load('x_train_3');
    x_train_3 = tl.('x_train_3');
    
    
    
    tl = load('x_test_1');
    x_test_1 = tl.('x_test_1');
    
    
    tl = load('x_test_2');
    x_test_2 = tl.('x_test_2');
    
    
    tl = load('x_test_3');
    x_test_3 = tl.('x_test_3');
    
    
end

rows.('x_train_1') = size(x_train_1);
rows.('x_test_1') = size(x_test_1);

rows.('x_train_2') = size(x_train_2);
rows.('x_test_2') = size(x_test_2);

rows.('x_test_3') = size(x_test_3);
rows.('x_train_3') = size(x_train_3);

clearvars x_train_1 y_train_1 x_train_2 y_train_2 x_train_3 y_train_3 x_test_1 x_test_2 x_test_3 recalculateFeatures y_test_1 y_test_2 y_test_3;

%% verify the contents
% DONE - load all the saved data from above and see under different
% conditions of test, train data



%% Step 4: Use the features to make models
disp('Making Models now');
% At this point, there are x_train, y_train variables saved in
% x_train_<patient_no> and x_test, y_test variables saved in
% y_test_<patient_no>

svmmodel = cell(3,1);

% cv = 0 -> training on complete data and testing on test data
if (cv==0)
    for patient = 1:3
        
        %number of predictions to be made
        numpredictions = 147500;
        
        if dolinearreg
            % linear regression
            [predicted_dg_lin{patient},pho_lin{patient}] = linearreg(config, patient, numpredictions);
        end
        
        if dosvr
            % SVR
            for finger = 1:5
                [svmmodel{patient}{finger}, a, b] = svm(config, patient, finger, 1, numpredictions);
                predicted_dg_svm{patient}(1:numpredictions,finger) = a;
                pho_svm{patient}(1,finger) = b;
            end
        end
        
        
    end
    
    % cv = 1 -> when training on some parts of training data and testing on
    % unseen parts of the testing data
elseif (cv==1)
    for patient = 1:3
        
        % number of predictions
        numpredictions = 310000*(1.0-ratio);
        
        if dolinearreg
            % linear regression
            [predicted_dg_lin{patient},pho_lin{patient}] = linearreg(config, patient, numpredictions);
        end
        
        if dosvr
            % SVR
            for finger = 1:5
                [svmmodel{patient}{finger}, a, b] = svm(config, patient, finger, 1,  numpredictions);
                predicted_dg_svm{patient}(1:numpredictions,finger) = a;
                pho_svm{patient}(1,finger) = b;
            end
        end
    end
    
    tempmean = [mean(cell2mat(pho{1})) mean(cell2mat(pho{2})) mean(cell2mat(pho{3}))];
    corr = mean(tempmean);
    
    
    % cv = 2 -> getting the training error when trained on complete data and
    % testing on complete data
elseif (cv==2)
    for patient = 1:3
        
        % number of predictions
        numpredictions = 310000;
        
        if dolinearreg
            % linear regression
            [predicted_dg_lin{patient},pho_lin{patient}] = linearreg(config, patient, numpredictions);
        end
        
        if dosvr
            % SVR
            for finger = 1:5
                [svmmodel{patient}{finger}, a, b] = svm(config, patient, finger, 1,  numpredictions);
                predicted_dg_svm{patient}(1:numpredictions,finger) = a;
                pho_svm{patient}(1,finger) = b;
            end
        end
        
        if dolasso
            
           for finger = 1:5
               
              a = lasso(config, patient, finger, 1, numpredictions); 
              predicted_dg_lasso{patient}(1:numpredictions, finger) = a;
              
           end
            
        end
        
    end
    
    tempmean = [mean(cell2mat(pho{1})) mean(cell2mat(pho{2})) mean(cell2mat(pho{3}))];
    corr = mean(tempmean);
    
end

predicted_dg = predicted_dg_svm;
save('predicted_dg.mat', 'predicted_dg');
