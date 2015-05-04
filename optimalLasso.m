% optimal lasso

load('lassolambda.mat');

optimallambda = zeros(3,5);
for patient = 1:3
    for finger = [1,2,3,5]
        
        for run = 1:3
        [a,b] = min(lambda{patient,finger}{run,1}.MSE)
        patient
        finger
        run
        m = lambda{patient,finger}{run,1}.Lambda(1,b);
        optimallambda(patient, finger) = optimallambda(patient, finger) + m
        
       end
    end
end

