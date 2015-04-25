% getperformance.m file


function[accuracy] = getperformance(str,predictions,patient,dataindices)
str = strcat(str,'_');

tl = load(strcat(str,num2str(patient)), strcat(str,num2str(patient)));
test_labels   = tl.(strcat(str,num2str(patient)));
test_labels = test_labels(dataindices,:);

temp_accuracy = cell(5,1);
temp_accuracy{1} = corr(predictions{patient}(:,1),test_labels(:,1));
temp_accuracy{2} = corr(predictions{patient}(:,2),test_labels(:,2));
temp_accuracy{3} = corr(predictions{patient}(:,3),test_labels(:,3));
temp_accuracy{4} = corr(predictions{patient}(:,4),test_labels(:,4));
temp_accuracy{5} = corr(predictions{patient}(:,5),test_labels(:,5));

accuracy = temp_accuracy;

end