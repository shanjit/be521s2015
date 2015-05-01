% lasso predictions
% [output] predicted_dg_lasso - 147500 * 5
% [output] lassoweights - (some number of models) * 5
% [output] pho_lasso - 1*1


function [predicted_dg_lasso,lassoweights,pho_lasso] = lasso_new(config, patient, numpredictions)

% getting data
tl = load(strcat('x_train_',num2str(patient)));
t2 = load(strcat('x_test_',num2str(patient)));
x_train = tl.(strcat('x_train_',num2str(patient)));
y_train = tl.(strcat('y_train_',num2str(patient)));
x_test = t2.(strcat('x_test_',num2str(patient)));
y_test = t2.(strcat('y_test_',num2str(patient)));

% finger wise y_train
y_train_finger = zeros(length(y_train));

pho_lasso = zeros(5);
lassoweights = zeros(length(y_train),5);
predicted_dg_lasso_array = zeros(length(x_train),5);

% size(x_train)
% size(y_train)
% size(x_test_local)
% size(y_test_local)
% size(x_test)


% for all fingers
for finger_index = 1:5
    
    fprintf('lasso model for patient %d finger %d\n',patient, finger_index);
    
    y_train_finger = y_train(:,finger_index);
    
    % lasso model
    [B, FitInfo] = lasso(x_train,y_train_finger);
    
    pred_y = zeros(size(B,2));
    corr_lasso = zeros(size(B,2));
    
    % finding optimal model
    intercept = FitInfo.Intercept;
    
    for B_index = 1:size(B,2)
        % predictions
        pred_y = x_test * B(:,B_index) + intercept(B_index); 
        % correlations
        corr_lasso(B_index) = corr(y_test,pred_y); 
    end
    
    % finding maximum correlation coefficient
    pho_lasso(finger_index) = find(corr_lasso == max(corr_lasso));
    
    % finding best model
    lassoweights(:,finger_index) = B(:,pho_lasso(finger_index));
    
    % predictions
    predicted_dg_lasso(:,finger_index) = x_test * lassoweights(:,finger_index);
    
end

end

