function [weights,r,r1] = getLinWeights(features)


N = 1:3;

noverlap = 50;


for patient = 1:3
    % load the corresponding data set and make it your train_data, train_labels
    % and test_data
    td = load(strcat('train_data_',num2str(patient)), strcat('train_data_',num2str(patient)));
    tl = load(strcat('train_labels_',num2str(patient)), strcat('train_labels_',num2str(patient)));
    
    train_data = td.(strcat('train_data_',num2str(patient)));
    train_labels   = tl.(strcat('train_labels_',num2str(patient)));
    
    
    R = getRMatrix(features,patient,N);
    
    % arrange labels again as well
    train1 = decimate(train_labels(:,1),noverlap);
    train2 = decimate(train_labels(:,2),noverlap);
    train3 = decimate(train_labels(:,3),noverlap);
    train4 = decimate(train_labels(:,4),noverlap);
    train5 = decimate(train_labels(:,5),noverlap);
    train = [train1 train2 train3 train4 train5];
    train = train(max(N)+1:size(features{patient},1),:);
    
    X{patient}.weights = mldivide((R'*R),(R'*train));
    
end

weights = X;

end

function [R] = getRMatrix(features,p,N)
hist = max(N);
rows_features = size(features{p},1);
no_of_features = size(features{p},2);
startpoint = hist+1;
timebins = (rows_features-hist);  %number of time bins
%create 'R' matrix for linear regression algorithm
r_train = zeros(timebins, no_of_features*hist+1);


% temp = 1;
for i = 1:timebins
    temp = features{p}(startpoint + (i-1) - N,:);   %temp is a temporary matrix
    r_train(i,:) = [1 temp(:)'];
    %     temp = 1;
end

R = r_train;
end


% function [R] = getRMatrix(features,p,N)
% % no. of rows features
% hist = max(N);
% d = size(features{p},2);
% 
% no_of_rows_test = size(features{p},1) - length(N);
% % final R matrix initialization
% testSet = zeros(no_of_rows_test,d*hist+1);
% % Initialize the first column as ones
% testSet(:,1) = ones(no_of_rows_test,1);
% % Fill the testing set depending on hist
% 
% for i = 1:d
%     for a = 1:hist
%         testSet(:, a +(i - 1)*hist + 1) = features{p}(a :a+no_of_rows_test-1,i);
%     end    
% end
% 
% R = testSet;
% 
% end
