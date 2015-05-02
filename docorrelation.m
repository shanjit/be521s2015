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

cv = 1;

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


    %
    % deleting x_all_3.mat forces newrun to evaluate the features atleast
    % once all over again.
    %
    % this ensures that you are dealing with the latest features always
    %
    
    
    %delete('x_all_3.mat');
    
    




if cv==1
    nooftimecv = 2;
    corr = cell(nooftimecv, 1);
    weights = cell(nooftimecv, 1);
    i=1;
    

    
    
    [corr{i}, weights{i}] =  newrun(cv, 0.95, 0, 0, 0, 1, config);
    % do cross validation for linear regression
    for i=2:nooftimecv
        % (cv, ratio, dolinearreg, dosvr, dolasso, config)
        [corr{i}, weights{i}] =  newrun(cv, 0.95, 0, 0, 0, 1, config);
        corr{i} .crosslinreg
        pause(5);
    end
    
    sum = 0;
    for i=1:nooftimecv
        % don't use abs, either all signs should be - or all +, if mixed
        % then things are wrong!
        % sum = sum + abs(corr{i}.crosslinreg);
        sum = sum + corr{i}.crosslinreg;
    end
    
    meancrosslinreg = sum/nooftimecv;
    
elseif cv==2
    
    [corr, weights] = newrun(cv, 0, 1, 0, 0, 1, config)
    
elseif cv==3
    
    finalrun(config, 1, 0, 0);
end