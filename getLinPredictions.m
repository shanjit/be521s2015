function [predictions] = getLinPredictions(weights, features, config, patient)


% noverlap samples of overlap between adjoining sections.
noverlap = config.('noverlap');

N = 1:config.('history');  


final_predictions = cell(3,1);


%for patient = 1:3

    R = getRMatrix(features, patient, N);
 
    u = R*(weights{patient}.weights);
    u = [zeros(max(N),5); u; zeros(1,5)];
    x = size(u,1);  
    temp1 = (1:x)*(noverlap/1000);
    
    % change temp2 if you want to use the training set when predicting
    temp2 = (1:147500)*(1/1000);
    
    for i = 1:5
    predictions(:,i) = spline(temp1,u(:,i),temp2)';
    
    % moving average filter to smooth stuff out
    predictions(:,i) = smooth(predictions(:,i),20,'moving'); % does rloess make a big difference 
    end
        
final_predictions{patient} = predictions;

%end

predictions = final_predictions;

end


function [R] = getRMatrix(features,p,N)
hist = max(N);
rows_features = size(features{p},1);
no_of_features = size(features{p},2);
startpoint = hist+1;
timebins = (rows_features-hist);

temp_R = zeros(timebins, no_of_features*hist+1);

for i = 1:timebins
    temp = features{p}(startpoint + (i-1) - N,:);
    temp_R(i,:) = [1 temp(:)'];
end

R = temp_R;
end
