function [finalpredictions, rho] = getLinPredictions(config, weights, patient, totalSize)

tl = load(strcat('x_test_',num2str(patient)));

x_test = tl.(strcat('x_test_',num2str(patient)));


noverlap = config.('noverlap');
N = config.('history');

u = x_test*(weights);
u = [zeros(max(N),5); u; zeros(1,5)];
x = size(u,1);
temp1 = (1:x)*(noverlap/1000);

temp2 = (1:totalSize)*(1/1000);

for i = 1:5
    predictions(:,i) = spline(temp1,u(:,i),temp2)';
    
%     
%     a = lpc(predictions(:,i),5);
%     predictions(:,i) = filter([0 -a(2:end)],1,predictions(:,i));
%     
    
    % moving average filter to smooth stuff out
    predictions(:,i) = smooth(predictions(:,i),20,'moving'); % does rloess make a big difference
    
    
    
end

finalpredictions = predictions;




y_test = tl.(strcat('y_test_',num2str(patient)));

if(y_test~=-1)
    u = y_test;
    u = [zeros(max(N),5); u; zeros(1,5)];
    x = size(u,1);
    temp1 = (1:x)*(noverlap/1000);
    
    temp2 = (1:totalSize)*(1/1000);
    
    for i = 1:5
        predictions(:,i) = spline(temp1,u(:,i),temp2)';
        
%         a = lpc(predictions(:,i),5);
%         predictions(:,i) = filter([0 -a(2:end)],1,predictions(:,i));
%     
%     
        % moving average filter to smooth stuff out
        predictions(:,i) = smooth(predictions(:,i),20,'moving'); % does rloess make a big difference
    
       
    end
    
    y_test = predictions;
    rho{1} = corr(y_test(:,1),finalpredictions(:,1));
    rho{2} = corr(y_test(:,2),finalpredictions(:,2));
    rho{3} = corr(y_test(:,3),finalpredictions(:,3));
    rho{4} = corr(y_test(:,4),finalpredictions(:,4));
    rho{5} = corr(y_test(:,5),finalpredictions(:,5));

elseif y_test==-1
    rho = -1;

end
    
end

