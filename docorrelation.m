% correlation file

cv = 1;

% window length in milliseconds
config.('window') = 100;
% number of history bits used : n-1 past and current
config.('history') = 4;
% overlap time in milliseconds
config.('noverlap') = 50;
% total 1024 points
config.('nfft') = 1024;
% freqbands used
config.('freqbands') = [5 15; 20 25; 75 115; 125 160; 160 175];
config.('fs') = 1000;

if cv == 1
    nooftimecv = 2;
    corr = cell(nooftimecv, 1);
    weights = cell(nooftimecv, 1);
    i = 1;
    [corr{i}, weights{i}] =  newrun(cv, 1, 0, 0.95, 0, 0, 1, config);
    % do cross validation for linear regression
    for i=2:nooftimecv
        % (cv, cvchanged, recalculatefeats ratio, dolinearreg, dosvr, dolasso, config)
        [corr{i}, weights{i}] =  newrun(cv, 1, 0, 0.95, 0, 0, 1, config);
        corr{i}.crosslasso
        pause(5);
    end
    
    sum = 0;
    for i=1:nooftimecv
        sum = sum + corr{i}.crosslasso;
    end
    
    meancrosslasso = sum/nooftimecv;
    
else
    
    [corr, weights] = newrun(cv, 0, 0, 1, 0, 0, 1, config)
    
end