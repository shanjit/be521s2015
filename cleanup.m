% cleanup script for removing everything we downloaded except the initial
% dataset 

%uncomment this to clean initial data also
% delete('train_*');
% delete('test_*');

% deletes all the files and features made my newrun and finalrun
delete('x_*');
delete('y_*');
