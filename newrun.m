% new run file to save the drunken electrodes

function [corr, retweights] = newrun (cv, cvchanged, recalculatefeats, ratio, dolinearreg, dosvr, dolasso, config)

% clean things
clearvars -except cv cvchanged ratio dolinearreg dosvr dolasso config recalculatefeats
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

linweights= cell(3,1);
svmmodel = cell(3,5);
lassoweights = cell(3,1);


% set 1 if you'd want to plot
doplot = 0;

%% Set what models are gonna be used for this run %%


% % set 1 if you'd want to use only linearreg
% dolinearreg = 1;
% 
% % set 1 if you'd want to use only svr
% dosvr = 0;
% 
% % set 1 if you'd want to use only lasso
% dolasso = 0;
% 
% %
% % CV SHOULD ONLY BE 1 OR 2 IN THIS FILE NOT 0!
% %
% % CV = 1 -> DEVELOP MODELS AND FIND THE ACCURACY FOR CROSS VALIDATIONS
% % CV = 2 -> DEVELOP MODELS FOR EXPORT TO THE FINALRUN.M FILE
% %
% cv = 1;
% 
% % safe bet keep cvchanged = 1, but if running this file multiple times then
% % cvchanged can be put to zero.
% cvchanged = 1;
% 
% % ratio of cross validation
% ratio = 0.90;


%% Define the configuration to get the R matrix from the raw EEG
% % window length in milliseconds
% config.('window') = 100;
% % number of history bits used : n-1 past and current
% config.('history') = 3;
% % overlap time in milliseconds
% config.('noverlap') = 50;
% % total 1024 points
% config.('nfft') = 1024;
% % freqbands used
% config.('freqbands') = [5 15; 20 25; 75 115; 125 160; 160 175];
% config.('fs') = 1000;


%% Get all the data from the portal %%
% don't redownload if the data already exists
% getData('shanjitsingh', 'login.bin');


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


% note that CV = 2 for this file always

% NOTE THAT this function needs to be called only once - the cv value will
% just shufle this and make train and test sets to be used only for this
% experiment
if recalculatefeats
    disp('Recalculating all the features');
    
    shuffleindices = randperm(310000);
    [x_train_1, y_train_1] = getFeatures(config, 1, shuffleindices, cv, ratio);
    save('x_all_1.mat','x_train_1','y_train_1');
    
    [x_train_2, y_train_2] = getFeatures(config, 2, shuffleindices, cv, ratio);
    save('x_all_2.mat','x_train_2','y_train_2');
    
    [x_train_3, y_train_3] = getFeatures(config, 3, shuffleindices, cv, ratio);
    save('x_all_3.mat','x_train_3','y_train_3');
    
    
else
    disp('Not recalculating features.');
    
end
clearvars x_train_1 y_train_1 x_train_2 y_train_2 x_train_3 y_train_3 x_test_1 x_test_2 x_test_3 recalculateFeatures y_test_1 y_test_2 y_test_3;


%
% CV SHOULD ONLY BE 1 OR 2 IN THIS FILE NOT 0!
%
% CV = 1 -> DEVELOP MODELS AND FIND THE ACCURACY FOR CROSS VALIDATIONS
% CV = 2 -> DEVELOP MODELS FOR EXPORT TO THE FINALRUN.M FILE
%
if (cv == 1)
    load('x_all_1');
    %sizex_train_1 = size(x_train_1);
    shuffleindices = randperm(size(x_train_1,1));
    tempxtrain = x_train_1(shuffleindices(1:floor(size(x_train_1,1)*ratio)),:);
    tempxtest = x_train_1(shuffleindices(1+floor(size(x_train_1,1)*ratio):end),:);
    
    tempytrain = y_train_1(shuffleindices(1:floor(size(x_train_1,1)*ratio)),:);
    tempytest = y_train_1(shuffleindices(1+floor(size(x_train_1,1)*ratio):end),:);
    
    x_train_1 = tempxtrain;
    x_test_1 = tempxtest;
    
    y_train_1 = tempytrain;
    y_test_1 = tempytest;
    
    clearvars tempxtrain tempytrain tempxtest tempytest
    
    
    load('x_all_2');
    %sizex_train_2 = size(x_train_2);
    shuffleindices = randperm(size(x_train_2,1));
    tempxtrain = x_train_2(shuffleindices(1:floor(size(x_train_2,1)*ratio)),:);
    tempxtest = x_train_2(shuffleindices(1+floor(size(x_train_2,1)*ratio):end),:);
    
    tempytrain = y_train_2(shuffleindices(1:floor(size(x_train_2,1)*ratio)),:);
    tempytest = y_train_2(shuffleindices(1+floor(size(x_train_2,1)*ratio):end),:);
    
    x_train_2 = tempxtrain;
    x_test_2 = tempxtest;
    
    y_train_2 = tempytrain;
    y_test_2 = tempytest;
    
    clearvars tempxtrain tempytrain tempxtest tempytest
    
    load('x_all_3');
    %sizex_train_3 = size(x_train_3);
    shuffleindices = randperm(size(x_train_3,1));
    tempxtrain = x_train_3(shuffleindices(1:floor(size(x_train_3,1)*ratio)),:);
    tempxtest = x_train_3(shuffleindices(1+floor(size(x_train_3,1)*ratio):end),:);
    
    tempytrain = y_train_3(shuffleindices(1:floor(size(x_train_3,1)*ratio)),:);
    tempytest = y_train_3(shuffleindices(1+floor(size(x_train_3,1)*ratio):end),:);
    
    x_train_3 = tempxtrain;
    x_test_3 = tempxtest;
    
    y_train_3 = tempytrain;
    y_test_3 = tempytest;
    
    clearvars tempxtrain tempytrain tempxtest tempytest
    
    
elseif (cv==2)
    load('x_all_1');
    tempxtrain = x_train_1;
    tempxtest = x_train_1;
    
    tempytrain = y_train_1;
    tempytest = y_train_1;
    
    x_train_1 = tempxtrain;
    x_test_1 = tempxtest;
    
    y_train_1 = tempytrain;
    y_test_1 = tempytest;
    
    clearvars tempxtrain tempytrain tempxtest tempytest
    
    load('x_all_2');
    tempxtrain = x_train_2;
    tempxtest = x_train_2;
    
    tempytrain = y_train_2;
    tempytest = y_train_2;
    
    x_train_2 = tempxtrain;
    x_test_2 = tempxtest;
    
    y_train_2 = tempytrain;
    y_test_2 = tempytest;
    
    clearvars tempxtrain tempytrain tempxtest tempytest
    
    load('x_all_3');
    tempxtrain = x_train_3;
    tempxtest = x_train_3;
    
    tempytrain = y_train_3;
    tempytest = y_train_3;
    
    x_train_3 = tempxtrain;
    x_test_3 = tempxtest;
    
    y_train_3 = tempytrain;
    y_test_3 = tempytest;
    
    
    clearvars tempxtrain tempytrain tempxtest tempytest
    
    
end


if cvchanged
    disp('Saving train, tests as CV changed. ');
    save('x_train_1.mat','x_train_1','y_train_1');
    save('x_test_1.mat', 'x_test_1', 'y_test_1');
    
    save('x_train_2.mat','x_train_2','y_train_2');
    save('x_test_2.mat', 'x_test_2', 'y_test_2');
    
    save('x_train_3.mat','x_train_3','y_train_3');
    save('x_test_3.mat', 'x_test_3', 'y_test_3');
    
    clearvars x_train_* x_test_* y_train_* y_test_*
    
else
    disp('Not saving train, tests as CV not changed.');
end



%% Use the saved features to make models
disp('Making Models now');
% At this point, there are x_train, y_train variables saved in
% x_train_<patient_no> and x_test, y_test variables saved in
% y_test_<patient_no>



% cv = 1 -> when training on some parts of training data and testing on
% unseen parts of the testing data
if (cv == 1)
   
    % number of predictions
    numpredictions = 310000 * (1.0 - ratio);
    
    if dolinearreg
        disp('Doing Linear Regression, calculating weights');
        for patient = 1:3
            % linear regression
            [predicted_dg_lin{patient}, linweights{patient}, pho_lin{patient}] = linearreg(config, patient, numpredictions);
        end
        
        
        pho = pho_lin;
        tempmean = [mean(cell2mat(pho_lin{1})) mean(cell2mat(pho_lin{2})) mean(cell2mat(pho{3}))];
        corr_lin = mean(tempmean);
        corr.('crosslinreg') = corr_lin;
        retweights.('crosslinreg') = linweights;
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
%         tempmean = [mean(cell2mat(pho_svm{1})) mean(cell2mat(pho_svm{2})) mean(cell2mat(pho_svm{3}))];
%         corr_svm = mean(tempmean);
%         corr.('crosssvm') = corr_svm;
        % retweights.('crossvm') = weights;
    end
    

    if dolasso
        for patient = 1:3
            [predicted_dg_lasso{patient}, lassoweights{patient}, pho_lasso{patient}] = lasso_new(config, patient, numpredictions);
        end
  
        pho = pho_lasso;
        tempmean = [mean(cell2mat(pho_lasso{1})) mean(cell2mat(pho_lasso{2})) mean(cell2mat(pho_lasso{3}))];
        corr_lasso = mean(tempmean);
        corr.('crosslasso') = corr_lasso;
        retweights.('crosslasso') = lassoweights;
%                 %[a,lambda1] = lassopred(config, patient, finger, 0, numpredictions);
%                 %lambda{patient,finger} = lambda1;
%                 
%                 [prediction] = lassopred(config, patient, finger, 0, numpredictions);
%                 predicted_dg_lasso{patient}(1:numpredictions,finger) = prediction;

        
%         tempmean = [mean(cell2mat(pho_svm{1})) mean(cell2mat(pho_svm{2})) mean(cell2mat(pho_svm{3}))];
%         corr_svm = mean(tempmean);
%         corr('trainlasso') = corr_lasso;
%         retweights('trainlasso') = lassoweights;
        
    end
    
    
    % collect individual phos and get the final pho
    %     tempmean = [mean(cell2mat(pho{1})) mean(cell2mat(pho{2})) mean(cell2mat(pho{3}))];
    %     corr = mean(tempmean);
    
    
    
    % cv = 2 -> getting the training error when trained on complete data and
    % testing on complete data
elseif (cv==2)
    
    
    % number of predictions
    numpredictions = 310000;
    
    if dolinearreg
        disp('Doing Linear Regression, calculating weights');
        for patient = 1:3
            % linear regression
            [predicted_dg_lin{patient}, linweights{patient}, pho_lin{patient}] = linearreg(config, patient, numpredictions);
        end
        
        
        pho = pho_lin;
        tempmean = [mean(cell2mat(pho_lin{1})) mean(cell2mat(pho_lin{2})) mean(cell2mat(pho{3}))];
        corr_lin = mean(tempmean);
        corr.('trainlinreg') = corr_lin;
        retweights.('trainlinreg') = linweights;

        % save the weights to a file for processing with finalrun.m
        % save('weight_linreg.mat','linweights');
        
    end
    
    if dosvr
        for patient=1:3
            for finger = 1:5
                [svmmodel{patient}{finger}, a, b] = svm(config, patient, finger, 1,  numpredictions);
                predicted_dg_svm{patient}(1:numpredictions,finger) = a;
                pho_svm{patient}(1,finger) = b;
            end
        end
        tempmean = [mean(cell2mat(pho_svm{1})) mean(cell2mat(pho_svm{2})) mean(cell2mat(pho_svm{3}))];
        corr_svm = mean(tempmean);
        corr.('trainsvm') = corr_svm;
        % savedweights('trainsvm') = weights;
    end
    
    if dolasso
        for patient = 1:3
            for finger = [1,2,3,5]
                finger
                
                %[a,lambda1] = lassopred(config, patient, finger, 0, numpredictions);
                %lambda{patient,finger} = lambda1;
                
                [prediction] = lassopred(config, patient, finger, 0, numpredictions);
                predicted_dg_lasso{patient}(1:numpredictions,finger) = prediction;
            end
        end
        
%         tempmean = [mean(cell2mat(pho_svm{1})) mean(cell2mat(pho_svm{2})) mean(cell2mat(pho_svm{3}))];
%         corr_svm = mean(tempmean);
%         corr.('trainlasso') = corr_lasso;
%         retweights.('trainlasso') = lassoweights;
        
    end
    
    
    
    
    
    
    %
    %
    %
    %     pho = pho_lin;
    %     tempmean = [mean(cell2mat(pho{1})) mean(cell2mat(pho{2})) mean(cell2mat(pho{3}))];
    %     corr = mean(tempmean);
    
end
% 
predicted_dg = predicted_dg_lin;
save('predicted_dg.mat', 'predicted_dg');

end