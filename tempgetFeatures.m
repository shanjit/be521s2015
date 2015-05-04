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
    averagetimevoltage = MovingWinFeats(data(:,i),fs, window/1000.0, noverlap/1000.0, TimeAvgVolt);
    
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