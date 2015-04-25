function [weights] = getLinWeights(patient)

tl = load(strcat('x_train_',num2str(patient)));

x_train = tl.(strcat('x_train_',num2str(patient)));
y_train = tl.(strcat('y_train_',num2str(patient)));

weights = mldivide((x_train'*x_train),(x_train'*y_train));

end


