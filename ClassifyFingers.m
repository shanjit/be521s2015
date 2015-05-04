function [finalPreds] = ClassifyFingers(cv, patienti)

tl = load('testTree.mat');
testTree = tl.(strcat('testTree', num2str(patienti)));

tl = load(strcat('test_data_', num2str(patienti)));
testData = tl.(strcat('test_data_', num2str(patienti)));

meanFcn = @(x) mean(x);
testData = MovingWinFeats(mean(testData, 2), 1, 50, 50, meanFcn);


predictions = predict(testTree, testData');

finalPreds = [];
for index = 1:length(predictions)
    finalPreds = [finalPreds (ones(1, 50)*predictions(index))];
end


end