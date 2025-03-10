% lasso predictions


function [predictions] = lasso(config, patient, finger, calclasso)

if(calclasso==1)
    disp('Recalculating Lasso Lambda models.');
    tl = load(strcat('x_train_',num2str(patient)));
    
    x_train = tl.(strcat('x_train_',num2str(patient)));
    y_train = tl.(strcat('y_train_',num2str(patient)));
    
    y_train = y_train(:,finger);
    
    nfolds = 3;
    data = [y_train, x_train];
    [learn, val] = kfolds(data,nfold);
    
    
    for i=1:nfolds
        
        lrndata.X = learn{i}(:, 2:end);
        lrndata.y = learn{i}(:, 1);
        valdata.X = val{i}(:, 2:end);
        valdata.y = val{i}(:, 1);
        [B, FitInfo] = lasso(lrndata.X, lrndata.y,'CV',10);
        
        train_predict = lrndata.X * B;
        val_predict = valdata.X * B;
        
        
        for i=size(train_predict,2)
            train_predict(:,i)=train_predict(:,i)+FitInfo.Intercept(i);
        end
        RHO = corr(train_predict,lrndata.y)
        figure()
        plot(FitInfo.DF,RHO);
        
        for i=size(val_predict,2)
            val_predict(:,i)=val_predict(:,i)+FitInfo.Intercept(i);
        end
        RHO = corr(val_predict,valdata.y)
        figure()
        plot(FitInfo.DF,RHO);
        
        % calculate the value of lambda
        
    end
    
end


% use the most appropriate value of lambda to find the predictions






end

