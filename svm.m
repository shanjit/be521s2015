% svm

function [svmmodel, prediction, acc] = svm(config, patient, finger, calcsvm, numofpredictions)



tl = load(strcat('x_test_',num2str(patient)));

x_test = tl.(strcat('x_test_',num2str(patient)));
y_test = tl.(strcat('y_test_',num2str(patient)));

if(y_test==-1)
  y_test = -1;
else
  y_test = y_test(:,finger);
end


if(calcsvm==1)
    disp('Recalculating SVM models.');
tl = load(strcat('x_train_',num2str(patient)));

x_train = tl.(strcat('x_train_',num2str(patient)));
y_train = tl.(strcat('y_train_',num2str(patient)));


param.s = 3; 					% epsilon SVR
param.C = 1;%max(y_train) - min(y_train);	% FIX C based on Equation 9.61
param.t = 2; 					% RBF kernel
param.gset = 2.^[-7:7];				% range of the gamma parameter
param.eset = [0:5];				% range of the epsilon parameter
param.nfold = 5 ;				% 5-fold CV




Rval = zeros(length(param.gset), length(param.eset));

y_train = y_train(:,finger);




% x_train, y_train

    data = [y_train, x_train];
    [learn, val] = kfolds(data,param.nfold);
    
for i = 1:param.nfold
    fprintf('Patient: %d, Finger: %d, Fold: %d \n', patient, finger, i);
    % partition the training data into the learning/validation
    % in this example, the 5-fold data partitioning is done by the following strategy,
    % for partition 1: Use samples 1, 6, 11, ... as validation samples and
    %			the remaining as learning samples
    % for partition 2: Use samples 2, 7, 12, ... as validation samples and
    %			the remaining as learning samples
    %   :
    % for partition 5: Use samples 5, 10, 15, ... as validation samples and
    %			the remaining as learning samples
    

    lrndata.X = learn{i}(:, 2:end);
    lrndata.y = learn{i}(:, 1);
    valdata.X = val{i}(:, 2:end);
    valdata.y = val{i}(:, 1);
    
    for j = 1:length(param.gset)
        param.g = param.gset(j);
        
        for k = 1:length(param.eset)
            param.e = param.eset(k);
            param.libsvm = ['-s ', num2str(param.s), ' -t ', num2str(param.t), ...
                ' -c ', num2str(param.C), ' -g ', num2str(param.g), ...
                ' -p ', num2str(param.e)];
            
            % build model on Learning data
            model = svmtrain(lrndata.y, lrndata.X, param.libsvm);
            
            % predict on the validation data
            [y_hat, Acc, projection] = svmpredict(valdata.y, valdata.X, model);
            
            Rval(j,k) = Rval(j,k) + mean((y_hat-valdata.y).^2);
        end
    end
    
end

Rval = Rval ./ (param.nfold);

[v1, i1] = min(Rval);
[v2, i2] = min(v1);
optparam = param;
optparam.g = param.gset( i1(i2) );
optparam.e = param.eset(i2);


optparam.libsvm = ['-s ', num2str(optparam.s), ' -t ', num2str(optparam.t), ...
		' -c ', num2str(optparam.C), ' -g ', num2str(optparam.g), ...
		' -p ', num2str(optparam.e)];


svmmodel{patient}{finger} = svmtrain(y_train, x_train, optparam.libsvm);


else
    
    if (y_test ~= -1)
    fprintf('Loading previous SVM models for patient %d, finger %d \n', patient, finger);
    load('svmmodel_predict_trainc2.mat')
    else
    fprintf('Loading previous SVM models for patient %d, finger %d \n', patient, finger);
    load('svmmodels.mat');
end
    


noverlap = config.('noverlap');
N = config.('history');
[y_hat, acc] = svmpredict(zeros(size(x_test,1),1), x_test, svmmodel{patient}{finger});

if y_test==-1
    acc = 0;
else
    acc = acc(2,1);
end

u = y_hat;


u = [zeros(max(N),1); u; zeros(1,1)];
x = size(u,1);
temp1 = (1:x)*(noverlap/1000);

temp2 = (1:numofpredictions)*(1/1000);

for i = 1:1
    predictions(:,i) = spline(temp1,u(:,i),temp2)';
    
    % moving average filter to smooth stuff out
    predictions(:,i) = smooth(predictions(:,i),20,'moving'); % does rloess make a big difference
end

prediction = predictions;
%finalpredictions = predictions;





end


