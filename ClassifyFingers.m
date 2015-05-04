    function [finalPreds] = ClassifyFingers(cv, patienti)
% Have train and test data and labels stored as train_data_*,
% test_data_*, and train_labels_* respectively before calling this
% function.
%
% This function will extract the data and labels, and find if any finger
% has moved for each patient at a given time point.
%
% When cv=1, cross validation will be done by splitting the data 95:5
% training:testing. nothing will be returned, but accuracy values will be
% displayed in the command window.
%
% When cv=0, entire train_data_* will be used to grow the decision tree,
% and testing will be done on test_data_* a vector containing 147500x3
% predictions will be returned containing finger predictions for each
% patient.

if cv
    % Cross Validation
    for patienti = 1:3
        % Load training data
        tl = load(strcat('train_data_', num2str(patienti)));
        data = tl.(strcat('train_data_', num2str(patienti)));
        
        % Load training labels
        tl = load(strcat('train_labels_', num2str(patienti)));
        labels = tl.(strcat('train_labels_', num2str(patienti)));
        
        % Define Feature
        meanFcn = @(x) mean(x);
        dataFeats = MovingWinFeats(mean(data, 2),...
            1, 50, 50, meanFcn); % Instead of channel selection,
        % the mean is taken over the 2nd
        % dimension (all the channels)
        % of our data
        
        % Downsample training labels for each finger
        for fingersi = 1:5
            dataLabels(:, fingersi) = downsample(labels(:, fingersi), 50, 25);
        end
        dataLabels = sum(dataLabels, 2);
        dataLabels = (dataLabels ~= 0)*1;
        
        % Data shuffling for cross validation
        dataLength = length(dataFeats);
        shuffleindices = randperm(dataLength);
        
        trainData = dataFeats(shuffleindices(1:0.95*dataLength));
        trainLabels = dataLabels(shuffleindices(1:0.95*dataLength));
        
        testData = dataFeats(shuffleindices((0.95*dataLength+1):end));
        testLabels = dataLabels(shuffleindices((0.95*dataLength+1):end));
        
        % Growing the decision tree and predicting either 0=no finger moved
        % OR 1=some finger moved
        tree = ClassificationTree.fit(trainData', trainLabels, 'ClassNames', [0 1]);
        predictions = predict(tree, testData');
        
        accuracy = sum(predictions == testLabels)/length(predictions)*100;
        fprintf('For patient %d, pre-expansion finger classification accuracy is %d \n', patienti, accuracy)
        
        finalPreds = [];
    end
    
    % No Cross Validation
elseif ~cv
    
        tl = load(strcat('train_data_', num2str(patienti)));
        data = tl.(strcat('train_data_', num2str(patienti)));
        
        % Load training labels
        tl = load(strcat('train_labels_', num2str(patienti)));
        labels = tl.(strcat('train_labels_', num2str(patienti)));
        
        % Downsample training labels for each finger
        dataLabels = zeros(310000/50, 5);
        for fingersi = 1:5
            dataLabels(:, fingersi) = downsample(labels(:, fingersi), 50, 25);
        end
        dataLabels = sum(dataLabels, 2);
        dataLabels = (dataLabels ~= 0)*1;
        
        % Load testing data
        tl = load(strcat('test_data_', num2str(patienti)));
        testData = tl.(strcat('test_data_', num2str(patienti)));
        
        meanFcn = @(x) mean(x);
        dataFeats = MovingWinFeats(mean(data, 2), 1, 50, 50, meanFcn);
        testData = MovingWinFeats(mean(testData, 2), 1, 50, 50, meanFcn);
        
        testTree = ClassificationTree.fit(dataFeats', dataLabels, 'ClassNames', [0 1]);
        predictions = predict(testTree, testData');
%         predictions = predictions';
        
        finalPreds = [];
        for index = 1:length(predictions)
            finalPreds = [finalPreds (ones(1, 50)*predictions(index))];
        end
        
    
end