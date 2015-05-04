% final file to be run to make the predictions
% this file will use the weights foudn earlier and then make predictions of
% the test data

function[predicted_dg] = finalrun(config, dolinearreg, dosvr, dolasso, doclassifyfinger, doregresstree, numpredictions)

% clean things
clearvars -except config dolinearreg dosvr dolasso doclassifyfinger doregresstree numpredictions
clc;
close all;


%% final weights/models/predictor variables to be saved %%
% save the final accuracies
pho_lin = cell(3,1);
pho_svm = cell(3,1);
pho_lasso = cell(3,1);

% final predictions are stored in this
predicted_dg_lin = cell(3,1);
predicted_dg_svm = cell(3,1);
predicted_dg_lasso = cell(3,1);
predicted_finger_movement = cell(3,1);
predicted_dg_regtree = cell(3,1);

svmmodel = cell(3,5);

%% Set what models are gonna be used for this run %%

%
% ONLY VARIABLE TO WORRY ABOUT :)
%

% always set recalculate feats unless you run this same file back to back
recalculatefeats = 0;

% CV SHOULD ONLY BE 0 IN THIS FILE
cv = 0;


%% Get all the data from the portal %%
% don't redownload if the data already exists
% getData('shanjitsingh', 'login,bin');


%% Use the saved features to make models
disp('Doing predictions now');
% At this point, there are x_train, y_train variables saved in
% x_train_<patient_no> and x_test, y_test variables saved in
% y_test_<patient_no>

% making finger classification now
%fingermove(config);


% number of predictions to be made
% numpredictions = 147500;

if dolinearreg
    disp('Doing prediction via linear regression');
    for patient = 1:3
        % linear regression
        load('weight_linreg');
        [predicted_dg_lin{patient},pho_lin{patient}] =  getLinPredictions(config,linweights{patient},patient,numpredictions);
    end
    
    %
    % change after you make other models
    %
    save('predicted_dg_lin.mat','predicted_dg_lin');

end

if dosvr
    for patient = 1:3
        % SVR
        for finger = 1:5
            [svmmodel{patient}{finger}, a, b] = svm(config, patient, finger, 1,  numpredictions);
            predicted_dg_svm{patient}(1:numpredictions,finger) = a;
            pho_svm{patient}(1,finger) = b;
        end
        
    end
end

if dolasso
    load('optimallambdalasso')
    for patient = 1:3
        for finger = 1:5
            [temp{patient}{finger}] = lassopred(config, patient, finger, intercept, lassoB, numpredictions, 0);
        end
    predicted_dg_lasso{patient} = [temp{patient}{1},temp{patient}{2},temp{patient}{3},temp{patient}{4},temp{patient}{5}];    
    end

    save('predicted_dg_lasso.mat','predicted_dg_lasso');
end

if doclassifyfinger
    for patient = 1:3
    predicted_finger_movement{patient} = ClassifyFingers(0,patient);   
    end
end

if doregresstree
    for patient = 1:3
        for finger = 1:5
            [temp{patient}{finger}] = regresspredict(config, patient, finger, numpredictions);
        end 
        predicted_dg_regtree{patient} = [temp{patient}{1},temp{patient}{2},temp{patient}{3},temp{patient}{4},temp{patient}{5}];    
    end
end

%
% create an ensemble here to make final predictions
%

for patient = 1:3
        predicted_dg{patient} = (0.7*predicted_dg_lasso{patient}) + (0.3*predicted_dg_lin{patient});% + predicted_dg_regtree{patient})/3.0;% (0.428*predicted_dg_lasso{patient} + 0.351*predicted_dg_lin{patient})/(0.428+0.351);
end
predicted_dg = predicted_dg';



% for rohit's finger classification code 
% for patient = 1:3
%     predicted_dg{patient}(find(predicted_finger_movement{patient}==0),:) = zeros(size(find(predicted_finger_movement{patient}==0),2),5);
% end


% max_predicted_dg = cell(3,1);
% min_predicted_dg = cell(3,1);
% 
% for i = 1:3
%     for j = 1:numpredictions
%         for k = 1:5
%             if(abs(predicted_dg{i}(j,k))<0.3)
%                 predicted_dg{i}(j,k) = 0;
%             end
%             %predicted_dg{i}(j,k) = fix(predicted_dg{i}(j,k));
%         end
% 
% 
%     end
% end
% 
% 
% 
% 
% for i = 1:3
%     for j = 1:numpredictions
%         for k = 1:5
%             if(abs(1-predicted_dg{i}(j,k))<0.1)
%                 predicted_dg{i}(j,k) = 1;
%             end
%             %predicted_dg{i}(j,k) = fix(predicted_dg{i}(j,k));
%         end
% 
% 
%     end
% end
% 
% 
% for i = 1:3
%     for j = 1:numpredictions
%         for k = 1:5
%             if(abs(2-predicted_dg{i}(j,k))<0.8)
%                 predicted_dg{i}(j,k) = 2;
%             end
%             %predicted_dg{i}(j,k) = fix(predicted_dg{i}(j,k));
%         end
% 
% 
%     end
% end
% 
% 
% for i = 1:3
%     for j = 1:numpredictions
%         for k = 1:5
%             if(abs(3-predicted_dg{i}(j,k))<0.4)
%                 predicted_dg{i}(j,k) = 3;
%             end
%             %predicted_dg{i}(j,k) = fix(predicted_dg{i}(j,k));
%         end
% 
% 
%     end
% end

% for i = 1:3
%     for j = 1:numpredictions
%         for k = 1:5
%             if(predicted_dg{i}(j,k)<-0.1)
%                 predicted_dg{i}(j,k) = -1;
%             end
%             %predicted_dg{i}(j,k) = fix(predicted_dg{i}(j,k));
%         end
%     end
% end



% for i = 1:3
%     for j = 1:numpredictions
%         for k = 1:5
%             if(abs(3-predicted_dg{i}(j,k))<0.4)
%                 predicted_dg{i}(j,k) = 3;
%             end
%             %predicted_dg{i}(j,k) = fix(predicted_dg{i}(j,k));
%         end
% 
% 
%     end
% end



% 
% for i = 1:3
%     for j = 1:numpredictions
%         for k = 1:5
%             if(abs(predicted_dg{i}(j,k))<0.4)
%                 predicted_dg{i}(j,k) = 0;
%             end
%         end
%     end
% end

% 
% for i = 1:3
%     for j = 1:numpredictions
%         for k = 1:5
%             if(abs(predicted_dg{i}(j,k))<0.3)
%                 predicted_dg{i}(j,k) = 0;
%             end
%         end
%     end
% end
% 


% for i = 1:1
%     for j = 1:numpredictions
%     predicted_dg{i}(j,find(predicted_dg{i}(j,:) ~= max(predicted_dg{i}(j,:)))) = zeros(1,size(find(predicted_dg{i}(j,:) ~= max(predicted_dg{i}(j,:))),2));
%     end
% end
delete('predicted_dg.mat')
save('predicted_dg.mat', 'predicted_dg');


end