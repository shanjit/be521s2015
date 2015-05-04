function [predicted_dg] = make_predictions(test_ecog)
%
% Inputs: test_ecog - 3 x 1 cell array containing ECoG for each subject, where test_ecog{i}
% to the ECoG for subject i. Each cell element contains a N x M testing ECoG,
% where N is the number of samples and M is the number of EEG channels.
% Outputs: predicted_dg - 3 x 1 cell array, where predicted_dg{i} contains the
% data_glove prediction for subject i, which is an N x 5 matrix (for
% fingers 1:5)
% Run time: The script has to run less than 1 hour. Any longer and the
%   team is disqualified from the final rankings.
% Errors or inability to handle test_data or output a correctly sized
%   predicted_dg result in automatic disqualification in the final
%   rankings.
%
% Any errors that are encountered during Tuesday, May 5, when the TAs are
% running each team's code will result in automatic disqualification of the
% team. Make sure to check with the TAs on Monday to ensure the script
% is properly finished and formatted. Remember the script and auxiliary
% files for the script is due 1:00 AM May 5th, 2015. Any team that submits this
% script as well as any other auxiliary files late is AUTOMATICALLY
% DISQUALIFIED from the final ranking.
%
% The following is a sample script.

% Load Model
% Imagine this mat file has the following variables:
% winDisp, filtTPs, trainFeats (cell array),

%load weights for each subject and each finger
%w is a 3 x 5 cell array, containing the weights for each subject per row,
%and model for each finger per column

% Predict using linear predictor for each subject
%create cell array with one element for each subject
% Correlation file
%
% with cv = 1, this will dump correlations and help with parameter
% selection
%
% with cv = 2, this will make final weights and models to be imported into
% finalrun.m file to get the predictions for the test_data.
%
% with cv = 3, you are making final predictions to be uploaded online. you
% should be uploading predicted_dg.mat online.
%
%
% NOTE: Please run cv = 1 then cv = 2 and then cv = 3
%
%
clc

test_data_1 = test_ecog{1};
save(strcat('test_data_', num2str(1)), 'test_data_1')

test_data_2 = test_ecog{2};
save(strcat('test_data_', num2str(2)), 'test_data_2')

test_data_3 = test_ecog{3};
save(strcat('test_data_', num2str(3)), 'test_data_3')

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

[x_test_1] = tempgetFeatures(config, 1, 'test_data', 'N/A');
save('x_test_1', 'x_test_1')
[x_test_2] = tempgetFeatures(config, 2, 'test_data', 'N/A');
save('x_test_2', 'x_test_2')
[x_test_3] = tempgetFeatures(config, 3, 'test_data', 'N/A');
save('x_test_3', 'x_test_3')
    
numpredictions = size(test_data_1, 1);
predicted_dg = finalrun(config, 1, 0, 1, 1, 0, numpredictions);

end