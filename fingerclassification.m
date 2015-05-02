% fingerclassification for finding out which finger moved if at all

function [fingerangle] = fingerclassification(config, patient)

%str1 = strcat('train_data_', num2str(patient));
str1= strcat('train_labels_', num2str(patient));
tl = load(str1);
train_labels = tl.(str1);



meanFeat = @(x) mean(x);

finger1label  = MovingWinFeats(train_labels(:,1), config.('fs'), config.('window')/1000, config.('noverlap')/1000, meanFeat);
finger2label  = MovingWinFeats(train_labels(:,2), config.('fs'), config.('window')/1000, config.('noverlap')/1000, meanFeat);
finger3label  = MovingWinFeats(train_labels(:,3), config.('fs'), config.('window')/1000, config.('noverlap')/1000, meanFeat);
finger4label  = MovingWinFeats(train_labels(:,4), config.('fs'), config.('window')/1000, config.('noverlap')/1000, meanFeat);
finger5label  = MovingWinFeats(train_labels(:,5), config.('fs'), config.('window')/1000, config.('noverlap')/1000, meanFeat);

finger1label = finger1label>0;
finger2label = (finger2label>0)*2;
finger3label = (finger3label>0)*3;
finger4label = (finger4label>0)*4;
finger5label = (finger5label>0)*5;

% fingerangle is either 0,1,2,3,4,5 refering to which finger was moved 
fingerangle = finger1label+finger2label+finger3label + finger4label + finger5label;

clearvars -except fingerangle patient


str3 = strcat('x_train_', num2str(patient));
td2 = load(str3);
train_data = td2.(str3);


str4 = strcat('x_test_', num2str(patient));
td3 = load(str4);
test_data = td3.(str4);

size(train_data)
size(fingerangle)

tree = ClassificationTree.fit(train_data,fingerangle);
test_predictions = predict(tree, test_data);
    



% 
% 
% % return positions of each finger 
% predicted_dg_lin{patient}




end
