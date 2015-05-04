% final file to be run to make the predictions
% this file will use the weights foudn earlier and then make predictions of
% the test data

function[] = finalrun(config, dolinearreg, dosvr, dolasso)

% clean things
clearvars -except config dolinearreg dosvr dolasso
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

% CV SHOULD ONLY BE 0 IN THIS FILE
cv = 0;


%% Get all the data from the portal %%
% don't redownload if the data already exists
getData('shanjitsingh', 'login,bin');



%% Step 2: Make all the features

% if recalculate feats is on then recalculate (default on)
if recalculatefeats
    disp('Recalculating all the features');
    
    % 
    % this is for shuffling raw eeg signals - our code doesn't do this
    % though.
    %
    shuffleindices = randperm(310000);
    
    delete('x_train_*');
    delete('x_test_*');
    
    [x_train_1, y_train_1, x_test_1, y_test_1] = getFeatures(config, 1, shuffleindices, cv, 0);
    save('x_train_1.mat','x_train_1','y_train_1');
    save('x_test_1.mat', 'x_test_1', 'y_test_1');
    
    [x_train_2, y_train_2, x_test_2, y_test_2] = getFeatures(config, 2, shuffleindices, cv, 0);
    save('x_train_2.mat','x_train_2','y_train_2');
    save('x_test_2.mat', 'x_test_2', 'y_test_2');
    
    [x_train_3, y_train_3, x_test_3, y_test_3] = getFeatures(config, 3, shuffleindices, cv, 0);
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


% number of predictions to be made
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
end

if dolasso
    for patient = 1:3
        % SVR
        for finger = 1:5
            [svmmodel{patient}{finger}, a, b] = svm(config, patient, finger, 1,  numpredictions);
            predicted_dg_lasso{patient}(1:numpredictions,finger) = a;
            pho_lasso{patient}(1,finger) = b;
        end
        
    end
end

%
% create an ensemble here to make final predictions
%
save('predicted_dg.mat', 'predicted_dg');
end