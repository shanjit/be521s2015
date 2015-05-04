% lasso predictions


function [finalpredictions, RetFitInfo] = lassopred(config, patient, finger, intercept, lassoB, numpredictions, calclasso)

if(calclasso==1)
    disp('Recalculating Lasso Lambda models.');
    tl = load(strcat('x_train_',num2str(patient)));
    
    x_train = tl.(strcat('x_train_',num2str(patient)));
    y_train = tl.(strcat('y_train_',num2str(patient)));
    
    
    for finger = 1:5
    y_train_temp = y_train(:,finger);
   
    
    [b,stats] = lasso(x_train, y_train_temp);    
    
   
    
    end
    nfolds = 3;
    
    data = [y_train, x_train];
    [learn, val] = kfolds(data,nfolds);
    
    %
    predictions = -1;
    arr = cell(3,1);
    %
    for i=1:nfolds
        %
        lrndata.X = learn{i}(:, 2:end);
        lrndata.y = learn{i}(:, 1);
        valdata.X = val{i}(:, 2:end);
        valdata.y = val{i}(:, 1);
        %
        [B, FitInfo] = lasso(lrndata.X, lrndata.y);
        
        arr{i} = FitInfo;
        
    end
    
    RetFitInfo = arr;
    
    
elseif(calclasso==0)
    disp('NOT Recalculating Lasso Lambda models.');
    noverlap = config.('noverlap');
    totalSize = numpredictions;
    N = config.('history');
    
    str = 'x_test_';
    
    tl = load(strcat(str,num2str(patient)));
    x_test = tl.(strcat(str,num2str(patient)));

        u = (x_test*lassoB{patient,finger}) + intercept{patient,finger}
        u = [zeros(max(N),1); u; zeros(1,1)];
        x = size(u,1);
        temp1 = (1:x)*(noverlap/1000);
        
        temp2 = (1:totalSize)*(1/1000);
        
        for i = 1:1
            predictions(:,i) = spline(temp1,u(:,i),temp2)';
            
            predictions(:,i) = smooth(predictions(:,i),20,'moving'); % does rloess make a big difference
            
        end
        

    finalpredictions = predictions;
    
    RetFitInfo = -1;
    
end






% use the most appropriate value of lambda to find the predictions

% lambda{patient}(1,1)/(2,1)




end

