% regression tree

function [finalpredictions] = regresspredict(config, patient, finger, numpredictions)

disp('Importing regression trees ');
noverlap = config.('noverlap');
totalSize = numpredictions;
N = config.('history');

str = 'x_test_';

tl = load(strcat(str,num2str(patient)));
x_test = tl.(strcat(str,num2str(patient)));

td = load(strcat('regtree',num2str(patient)));
model = td.(strcat('nc',num2str(patient),num2str(finger)));

u = predict(model, x_test);
u = [zeros(max(N),1); u; zeros(1,1)];
x = size(u,1);
temp1 = (1:x)*(noverlap/1000);

temp2 = (1:totalSize)*(1/1000);

for i = 1:1
    predictions(:,i) = spline(temp1,u(:,i),temp2)';
    
    predictions(:,i) = smooth(predictions(:,i),20,'moving'); % does rloess make a big difference
    
end


finalpredictions = predictions;


end