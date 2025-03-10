% After running this function the following files are created in your home
% directory
% train_data_<patient_no> = the training data for a patient of <patient_no>
% test_data_<patient_no> = the testing data for a patient of <patient_no>
% train_labels_<patient_no> = the training labels for a patient of
% <patient_no>
% temp_train_data_<patient_no> - training set for measuring training error
% temp_test_data_<patient_no> - testing set for measuring training error
% temp_train_labels_<patient_no> - training labels for making model
% temp_test_labels_<patient_no> - testing labels for meas. training error

function[] = getData(username, loginfile)
% Run this script once to get all the data

% if data not downloaded then download
if (exist('test_data_3.mat','file')~=2)
    % Patient 1 
    % Properties of the dataset 
    % Total number of train samples = 310000 on 62 channels
    % Total number of testing samples = 147500 on 62 channels
    % train labels has 310000 samples of 62 channels, we need to predict the
    % labels for thisuntitled

    session1 = IEEGSession('I521_A0012_D001', username, loginfile);
    session2 = IEEGSession('I521_A0012_D002', username, loginfile);
    session3 = IEEGSession('I521_A0012_D003', username, loginfile);
    train_data_1 = session1.data.getvalues(1:310000,1:62);
    train_labels_1 = session2.data.getvalues(1:310000, 1:5);
    test_data_1 = session3.data.getvalues(1:147500,1:62);
    
    
    % train_data_1 = 310000 x 62
    save('train_data_1.mat','train_data_1');
    
    % train_labels_1 = 310000 x 5
    save('train_labels_1.mat','train_labels_1');
    
    % train_data_1 = 147500 x 5
    save('test_data_1.mat','test_data_1');


    % Patient 2
    % Properties of the dataset 
    % Total number of train samples = 310000 on 48 channels
    % Total number of testing samples = 147500 on 48 channels
    % train labels has 310000 samples of 48 channels, we need to predict the
    % labels for this

    close all;
    clearvars -except username loginfile
    clc;
    session1 = IEEGSession('I521_A0013_D001', username, loginfile);
    session2 = IEEGSession('I521_A0013_D002', username, loginfile);
    session3 = IEEGSession('I521_A0013_D003', username, loginfile);
    train_data_2 = session1.data.getvalues(1:310000,1:48);
    train_labels_2 = session2.data.getvalues(1:310000, 1:5);
    test_data_2 = session3.data.getvalues(1:147500,1:48);
    
    
    save('train_data_2.mat','train_data_2');
    
    save('train_labels_2.mat','train_labels_2');
    
    save('test_data_2.mat','test_data_2');


    
    
    % Patient 3
    % Properties of the dataset 
    % Total number of train samples = 310000 on 64 channels
    % Total number of testing samples = 147500 on 64 channels
    % train labels has 310000 samples of 64 channels, we need to predict the
    % labels for this
    close all;
    clearvars -except username loginfile
    clc;

    session1 = IEEGSession('I521_A0014_D001', username, loginfile);
    session2 = IEEGSession('I521_A0014_D002', username, loginfile);
    session3 = IEEGSession('I521_A0014_D003', username, loginfile);
    
    train_data_3 = session1.data.getvalues(1:310000,1:64);
    train_labels_3 = session2.data.getvalues(1:310000, 1:5);
    test_data_3 = session3.data.getvalues(1:147500,1:64);
    

    save('train_data_3.mat','train_data_3');
    save('train_labels_3.mat','train_labels_3');
    save('test_data_3.mat','test_data_3');
    clearvars -except username loginfile
    clc;
    close all;
    
% if data is already downloaded, then display and return
else 
    disp('All data is already downloaded.');

end

end
