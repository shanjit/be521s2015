% feature extraction from the downloaded data
% inputs - 'test_data' or 'train_data' to choose whose features to generate
% outputs - saves either features_train.mat or features_test.mat
% NOTE: running this file again will recalculate all features and overwrite
% the files.


function[xtrain, ytrain, xtest, ytest] = getFeatures(config, patient, shuffleindices, cv, ratio)


%
% when trainging on the complete data and predicting on the test data given
% 
if(cv==0)
   xtrain = tempgetFeatures(config, patient, 'train_data', 1:310000);
   ytrain = tempgetLabels(patient, config, size(xtrain,1), 1:310000);
   xtest =  tempgetFeatures(config, patient, 'test_data', 1:147500);
   ytest =  -1;
   % good to return
   
%
% when training on some part of the training data and testing on the unseen
% data (training data)
%
elseif(cv==1)
    xtrain = tempgetFeatures(config, patient, 'train_data', shuffleindices(1:310000*ratio) );
    xtest = tempgetFeatures(config, patient, 'train_data', shuffleindices(1+(310000*ratio):end));
    
    ytrain = tempgetLabels(patient, config, size(xtrain,1), shuffleindices(1:310000*ratio));
    ytest = tempgetLabels(patient, config, size(xtest,1), shuffleindices(1+(310000*ratio):end ));

%
% when training on the complete data and testing on the complete data for
% the training error
%
elseif(cv==2)
    xtrain = tempgetFeatures(config, patient, 'train_data', 1:310000);
    ytrain = tempgetLabels(patient, config, size(xtrain,1), 1:310000);
    xtest = xtrain;
    ytest = ytrain;
   
end

% matrix normalization and 
% [x_train, x_test] = featureNorm(xtrain, xtest, xtrain, 0, 1);
% xtrain = x_train(:,2:end);
% xtest = x_test(:,2:end);



end

function[ytrain] = tempgetLabels(patient, config, n, shuffleindices)

noverlap = config.('noverlap');
N = config.('history');

tl = load(strcat('train_labels_',num2str(patient)));
train_labels   = tl.(strcat('train_labels_',num2str(patient)));    

%%%% NO SHUFFLING OF THE RAW EEG %%%% 
%%%%                             %%%%
% uncomment the line below for shuffling if needed
%train_labels = train_labels(shuffleindices, :);


train1 = decimate(train_labels(:,1),noverlap);
train2 = decimate(train_labels(:,2),noverlap);
train3 = decimate(train_labels(:,3),noverlap);
train4 = decimate(train_labels(:,4),noverlap);
train5 = decimate(train_labels(:,5),noverlap);
train = [train1 train2 train3 train4 train5];
train = train(max(N)+1:n+max(N),:);

ytrain = train;


end

function[xtrain] = tempgetFeatures(config, patient, str, shuffleindices)
str = strcat(str,'_');

TimeAvgVolt = @(x)mean(x);

% define frequency bands in hertz
freqbands = config.('freqbands');

% spectrogram definitions - http://www.mathworks.com/help/signal/ref/spectrogram.html
% s = spectrogram(x) returns the short-time Fourier transform of the input signal, x.
% Each column of s contains an estimate of the short-term, time-localized frequency content of x.

% window to divide the signal into sections and perform windowing
window = config.('window');
% noverlap samples of overlap between adjoining sections.
noverlap = config.('noverlap');
% nfft sampling points to calculate the discrete Fourier transform.
nfft = config.('nfft');
% sampling frequency
fs = config.('fs');

N = 1:config.('history');

% feature_matrix cells to store features for each matrix
featurematrix = cell(3,1);

% load the corresponding data set per patient
td = load(strcat(str,num2str(patient)));

% data is samples x channel number
data = td.(strcat(str,num2str(patient)));


%%%% NO SHUFFLING OF THE RAW EEG %%%% 
%%%%                             %%%%
% uncomment the line below for shuffling if needed
%data = data(shuffleindices,:);


% clear unnecessary variables
clearvars td

% for each column of the dataset
for i = 1:size(data,2)
    
    % get spectrogram and frequency bins over each channel
    % F is vector of cyclic frequencies
    % Each column of S is an estimate of the short term, time localized
    % frequency content of X
    [S, F] = spectrogram(data(:,i), window, noverlap, nfft, fs);
    
    % find average frequency-domain magnitude in five frequency bands
    % (freqbands)
    freqfeatures = zeros(size(freqbands,1),size(S,2));
    for j = 1:size(freqfeatures)
        bandInds = F >= freqbands(j,1) & F <= freqbands(j,2);
        freqfeatures(j,:) = mean(abs(S(bandInds,:)),1);
    end
    
    % remember everything is in seconds in the MovingWinFeature
    averagetimevoltage = MovingWinFeats(data(:,i),1000, window/1000.0, noverlap/1000.0, TimeAvgVolt);
    
    % find more features in the similar fashion
    %
    %
    %
    
    featurematrix{patient} = [featurematrix{patient} freqfeatures' averagetimevoltage'];
    
    
    
end


% calculate the R matrix
xtrain = getRMatrix(featurematrix,patient,N);

end




function [R] = getRMatrix(features,p,N)
hist = max(N);
rows_features = size(features{p},1);
no_of_features = size(features{p},2);
startpoint = hist+1;
timebins = (rows_features-hist);  %number of time bins
%create 'R' matrix for linear regression algorithm
r_train = zeros(timebins, no_of_features*hist+1);


% temp = 1;
for i = 1:timebins
    temp = features{p}(startpoint + (i-1) - N,:);   %temp is a temporary matrix
    r_train(i,:) = [1 temp(:)'];
    %     temp = 1;
end

R = r_train;
end