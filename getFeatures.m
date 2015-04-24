% feature extraction from the downloaded data
% inputs - 'test_data' or 'train_data' to choose whose features to generate
% outputs - saves either features_train.mat or features_test.mat
% NOTE: running this file again will recalculate all features and overwrite
% the files.

function[features] = getFeatures(str, config, patient)

% define the other feature functions which you'd like to use here
TimeAvgVolt = @(x)mean(x)

str = strcat(str,'_');

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

% feature_matrix cells to store features for each matrix
featurematrix = cell(3,1);

% for each patient
%for patient = 1:3
    
    % load the corresponding data set per patient
    td = load(strcat(str,num2str(patient)), strcat(str,num2str(patient)));
    
    % data is samples x channel number
    data = td.(strcat(str,num2str(patient)));
    
    % clear unnecessary variables
    clearvars td
    
    % for each channel
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
    
%end


str = strsplit(str,'_');
str = str{1};
if (strcmp(str,'test'))
    feature_matrix_test = featurematrix;
    %save(strcat('features_',str,'.mat'),'feature_matrix_test');
    
    
elseif(strcmp(str,'train'))
    feature_matrix_train = featurematrix;
    %save(strcat('features_',str,'.mat'),'feature_matrix_train');
    
end


features = featurematrix;

end


function [Output] = MovingWinFeats(x, fs, winLen, winDisp, featFn)
% MovingWinFeats(y,100,0.5,0.25,LLFn) - EVERYTHING IS IN SECONDS
NumWins = @(xLen,fs,winLen,winDisp) floor(((xLen) - (winLen*fs))/(winDisp*fs))+1;
i = 1;
j = fs*winLen;

for n=1:NumWins(length(x),fs, winLen, winDisp)
    Output(1,n)=featFn(x(i:j));
    i= i+fs*winDisp;
    j= j+fs*winDisp;
end
end

