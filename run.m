% final script to always run

clear all;
clc;

% Step 1: Get all the data
getData;


% design choice if you'd like to use this 
config.('window') = 100; %ms
config.('history') = 3; % n-1 past and current
config.('noverlap') = 50; %ms
config.('nfft') = 1024; % total 1024 points
config.('freqbands') = [5 15; 20 25; 75 115; 125 160; 160 175];
config.('fs') = 1000;


% Step 2: Get all the Features
% todo: implement more features
%       feature reduction using PCA or whatever
features_train = getFeatures('train_data', config, 1);
features_test = getFeatures('test_data', config, 1);


% Step 3: apply models and make predictions

% Step 3.1: Apply linear models
linweights = getLinWeights(features_train, config, 1);
predictions = getLinPredictions(linweights, features_test, config, 1);


% Step 3.2: Apply other models


% Step 3.x: Make an ensemble 

% Step 4: Save the final predictions and upload online
