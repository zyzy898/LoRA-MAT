function [Data14,Data15,Data16 ] = Data_deviding( start_month,end_month )


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs: start_month -> the data deviding start with this month 
%         end_month -> the data deviding ends with this month 

% Outputs: Data14 -> data chosen from 2014
%          data15 -> data chosen from 2015
%          data16 -> data chosen from 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Loads all attributes data from all data sets 
load('Wind16.mat')
load('Wind15.mat')
load('Wind14.mat')
load('Sun16.mat')
load('Sun15.mat')
load('Sun14.mat')
load('Rtemp16.mat')
load('Rtemp15.mat')
load('Rtemp14.mat')
load('Ptemp16.mat')
load('Ptemp15.mat')
load('Ptemp14.mat')
load('Datetime16.mat')
load('Datetime15.mat')
load('Datetime14.mat')

%%%%%%%%%%%%%%%% get the right index from data set %%%%%%%%%%
    if start_month==1
            start_month=1;
        elseif start_month==2
            start_month=2977;

        elseif start_month==3
            start_month=5665;
            
        elseif start_month==4
            start_month=8637;
        
    elseif start_month==5
            start_month=11517;
    
    elseif start_month==6
            start_month=14493;
    
    elseif start_month==7
            start_month=17373;
    
    elseif start_month==8
            start_month=20349;
    
    elseif start_month==9
            start_month=23325;
      
    elseif start_month==10
            start_month=26205;
    
    elseif start_month==11
            start_month=29185;
    
    else
            start_month=32065;
    end
    
%%%%%%%%%%%%%%%% Get the right index from data set  %%%%%%%%%%
    if end_month==1 
        end_month=2976;
    elseif end_month==2
        end_month=5664;

    elseif end_month==3
        end_month=8636;

        elseif end_month==4
        end_month=11516;
        elseif end_month==5
        end_month=14492;
        elseif end_month==6
        end_month=17372;
        elseif end_month==7
        end_month=20348;
        elseif end_month==8
        end_month=23324;
        elseif end_month==9
        end_month=26204;
        elseif end_month==10
        end_month=29184;
        elseif end_month==11
        end_month=32064;
      else
        end_month=35040;
    end 
%%%%%%%%%%%%%%% Put the desired data into corresponding data set
Data14(:,:,:,:)=[Wind14(start_month:end_month,:) Sun14(start_month:end_month,:) Ptemp14(start_month:end_month,:)   Rtemp14(start_month:end_month,:)];
Data15(:,:,:,:)=[Wind15(start_month:end_month,:) Sun15(start_month:end_month,:) Ptemp15(start_month:end_month,:)   Rtemp15(start_month:end_month,:)];
Data16(:,:,:,:)=[Wind16(start_month:end_month,:) Sun16(start_month:end_month,:) Ptemp16(start_month:end_month,:)   Rtemp16(start_month:end_month,:)];



end

