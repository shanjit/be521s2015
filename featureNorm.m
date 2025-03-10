function [trndata,valdata,tstdata,udata]=featureNorm(trndata,valdata,tstdata,Lower,Upper,udata)
%--------------------------------------------------------------------------
% DESCRIPTION: Used to Scale data uniformly
%--------------------------------------------------------------------------
Data=trndata;
[MaxV, I]=max(Data);
[MinV, I]=min(Data);
[R,C]= size(Data);
scaled=(Data-ones(R,1)*MinV).*(ones(R,1)*((Upper-Lower)*ones(1,C)./(MaxV-MinV)))+Lower;
for i=1:size(Data,2)
    if(all(isnan(scaled(:,i))))
        scaled(:,i)=0;
    end
end
trndata=scaled;

%######## SCALE THE VAL DATA TO THE RANGE OF TRAINING DATA ##########
Data=valdata;
[R,C]= size(Data);
scaled=(Data-ones(R,1)*MinV).*(ones(R,1)*((Upper-Lower)*ones(1,C)./(MaxV-MinV)))+Lower;
for i=1:size(Data,2)
    if(all(isnan(scaled(:,i))))
        scaled(:,i)=0;
    end
end
valdata=scaled;

%###### SCALE THE TEST DATA TO THE RANGE OF TRAINING DATA ###########
Data=tstdata;
[R,C]= size(Data);
scaled=(Data-ones(R,1)*MinV).*(ones(R,1)*((Upper-Lower)*ones(1,C)./(MaxV-MinV)))+Lower;
for i=1:size(Data,2)
    if(all(isnan(scaled(:,i))))
        scaled(:,i)=0;
    end
end
tstdata=scaled;

%###### SCALE THE U DATA TO THE RANGE OF TRAINING DATA ###########

if(nargin==6)
    Data=udata;
    [R,C]= size(Data);
    scaled=(Data-ones(R,1)*MinV).*(ones(R,1)*((Upper-Lower)*ones(1,C)./(MaxV-MinV)))+Lower;
    for i=1:size(Data,2)
        if(all(isnan(scaled(:,i))))
            scaled(:,i)=0;
        end
    end
    udata=scaled;
end

