% lasso predictions
% [output] predicted_dg_lasso - 147500 * 5
% [output] lassoweights - (some number of models - generally 100) * 5
% [output] pho_lasso - 5*1
% [input] config
% [input] patient
% numpredictions

function [predicted_dg_lasso, lassoweights, pho_lasso] = lasso_new(config, patient, numpredictions)

fprintf('lasso for patient %d\n',patient);
predicted_dg_lasso = cell(3,1);

% getting data
tl = load(strcat('x_train_',num2str(patient)));
t2 = load(strcat('x_test_',num2str(patient)));
x_train = tl.(strcat('x_train_',num2str(patient)));
y_train = tl.(strcat('y_train_',num2str(patient)));
x_test = t2.(strcat('x_test_',num2str(patient)));
y_test = t2.(strcat('y_test_',num2str(patient)));

% finger wise y_train
y_train_finger = zeros(length(y_train),1);

% finger wise y_test
y_test_finger = zeros(length(y_test),1);

% pho_lasso = cell(3,1);
% lassoweights = cell(3,1);
% predicted_dg_lasso = cell(3,1);

% size(x_train)
% size(y_train)
% size(x_test_local)
% size(y_test_local)
% size(x_test)


% for all fingers
for finger_index = 1:5
    
    fprintf('lasso model for patient %d finger %d\n',patient, finger_index);
    
    y_train_finger = y_train(:,finger_index);
    y_test_finger = y_test(:,finger_index);
    pho_lasso_max_index = 0;
    
%     size(y_train_finger)
    
    % lasso model
    [B, FitInfo] = lasso(x_train,y_train_finger);
    
%     size(B)
    
    pred_y = zeros(size(x_test,1),1);
    corr_lasso = zeros(size(B,2),1);
    
    % finding optimal model
    intercept = FitInfo.Intercept;
    
    for B_index = 1:size(B,2)
        % predictions
        pred_y = x_test * B(:,B_index) + intercept(B_index); 
        % correlations - ERROR: size difference 
        corr_lasso(B_index) = corr(y_test_finger,pred_y); 
    end
    
%     size(corr_lasso)
    
    % finding maximum correlation coefficient
    pho_lasso_max_index = find(corr_lasso == max(corr_lasso));
    pho_lasso{patient}(finger_index) = corr_lasso(pho_lasso_max_index);
    
    % finding best model
    lassoweights{patient}(:,finger_index) = B(:,pho_lasso_max_index);
    
    % predictions - x_test = test_data_1 for patient 1 ??? if yes, then
    % how to match lassoweight dimensions to it ?
%     predicted_dg_lasso(:,finger_index) = x_test * lassoweights(:,finger_index);
    
end

end

