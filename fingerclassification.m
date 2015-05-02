% fingerclassification for finding out which finger moved if at all

function [predictions, retcorr] = fingerclassification(config, patient)

% x_train_<patient> / x_test_<patient> 
% y_train_<patient> / y_train_<patient>
% finger_train_<patient> / finger_test_<patient>

str = strcat('x_train_', num2str(patient));
td = load(str);

str1 = strcat('x_train_', num2str(patient));
str3 = strcat('finger_train_', num2str(patient));

x_train = td.(str1);
finger_train = td.(str3);

% disp('giving sizes')
% size(x_train)
% size(finger_train)
tree = ClassificationTree.fit(x_train,finger_train);


str = strcat('x_test_', num2str(patient));
tl = load(str);

str1 = strcat('x_test_', num2str(patient));
str3 = strcat('finger_test_', num2str(patient));

x_test = tl.(str1);
finger_test = tl.(str3);

% accuracy would be the correlation between test_predictions and
% finger_test
test_predictions = predict(tree, x_test);


predictions = test_predictions;
retcorr = corr(test_predictions, finger_test)




end
