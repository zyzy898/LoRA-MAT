function DecisionTree

train = load('hw3train.txt');
Split(train);
end

function Split(train)
allEqual =  true;

for i=1:size(train,1) %check if the data set is pure or not
    if(train(1,5) ~= train(i,5))
        allEqual = false;
    end
end

if(allEqual ~= true) %then we have an impure node
%find the max information gained to obtain splitting rule

%first calculate H(S), to calculate this we need
    oneCount = 0;
    twoCount = 0;
    threeCount = 0;
    totalCount = size(train,1);

    for i=1:size(train,1)
        if(train(i,5) == 1)
            oneCount = oneCount + 1;
        elseif(train(i,5) == 2)
            twoCount = twoCount + 1;
        else
            threeCount = threeCount + 1;
        end
    end

    HS = -nansum((oneCount/totalCount) * log(oneCount/totalCount)) -nansum((twoCount/totalCount) * log(twoCount/totalCount)) -nansum((threeCount/totalCount) * log(threeCount/totalCount))

%now that we got the H(S), we have to calculate all H(S|A) to find which is
%best to split to maximize IG

IG = [0; 0; 0;]; %value i j

for i=1:size(train,1)
    oneCountLTE1 = 0;
    twoCountLTE1 = 0;
    threeCountLTE1 = 0;
    oneCountGT1 = 0;
    twoCountGT1 = 0;
    threeCountGT1 = 0;
    oneCountLTE2 = 0;
    twoCountLTE2 = 0;
    threeCountLTE2 = 0;
    oneCountGT2 = 0;
    twoCountGT2 = 0;
    threeCountGT2 = 0;
    oneCountLTE3 = 0;
    twoCountLTE3 = 0;
    threeCountLTE3 = 0;
    oneCountGT3 = 0;
    twoCountGT3 = 0;
    threeCountGT3 = 0;
    oneCountLTE4= 0;
    twoCountLTE4 = 0;
    threeCountLTE4 = 0;
    oneCountGT4 = 0;
    twoCountGT4 = 0;
    threeCountGT4 = 0;
    %calculate H(A,B,C,D<=X) for all features A,B,C,D <= X
    for j=1:size(train,1)
        if(train(j,1) <= train(i,1))    %goes through feature 1 (column 1) to find the counts
            if(train(j,5) == 1)
                oneCountLTE1 = oneCountLTE1 + 1;
            elseif(train(j,5) == 2)
                twoCountLTE1 = twoCountLTE1 + 1;
            else
                threeCountLTE1 = threeCountLTE1 + 1;
            end
        else
            if(train(j,5) == 1)
                oneCountGT1 = oneCountGT1 + 1;
            elseif(train(j,5) == 2)
                twoCountGT1 = twoCountGT1 + 1;
            else
                threeCountGT1 = threeCountGT1 + 1;
            end
        end
        
        if(train(j,2) <= train(i,2))
            if(train(j,5) == 1)
                oneCountLTE2 = oneCountLTE2 + 1;
            elseif(train(j,5) == 2)
                twoCountLTE2 = twoCountLTE2 + 1;
            else
                threeCountLTE2 = threeCountLTE2 + 1;
            end
        else
            if(train(j,5) == 1)
                oneCountGT2 = oneCountGT2 + 1;
            elseif(train(j,5) == 2)
                twoCountGT2 = twoCountGT2 + 1;
            else
                threeCountGT2 = threeCountGT2 + 2;
            end
        end
        
        if(train(j,3) <= train(i,3))
            if(train(j,5) == 1)
                oneCountLTE3 = oneCountLTE3 + 1;
            elseif(train(j,5) == 2)
                twoCountLTE3 = twoCountLTE3 + 1;
            else
                threeCountLTE3 = threeCountLTE3 + 1;
            end
        else
            if(train(j,5) == 1)
                oneCountGT3 = oneCountGT3 + 1;
            elseif(train(j,5) == 2)
                twoCountGT3 = twoCountGT3 + 1;
            else
                threeCountGT3 = threeCountGT3 + 1;    
            end
        end
        
        if(train(j,4) <= train(i,4))
            if(train(j,5) == 1)
                oneCountLTE4 = oneCountLTE4 + 1;
            elseif(train(j,5) == 2)
                twoCountLTE4 = twoCountLTE4 + 1;
            else
                threeCountLTE4 = threeCountLTE4 + 1;
            end
        else
            if(train(j,5) == 1)
                oneCountGT4 = oneCountGT4 + 1;
            elseif(train(j,5) == 2)
                twoCountGT4 = twoCountGT4 + 1;
            else
                threeCountGT4 = threeCountGT4 + 1;    
            end
        end
    end
    
        %now we got the counts to all compared to the ones at row i that 
        %are <= and > we can calculate
        %the IG
        
    totalCountLTE1 = oneCountLTE1+twoCountLTE1+threeCountLTE1;
    HLTE1 = -nansum((oneCountLTE1/totalCountLTE1) * log(oneCountLTE1/totalCountLTE1)) -nansum((twoCountLTE1/totalCountLTE1) * log(twoCountLTE1/totalCountLTE1)) -nansum((threeCountLTE1/totalCountLTE1) * log(threeCountLTE1/totalCountLTE1));
        
    totalCountGT1 = oneCountGT1+twoCountGT1+threeCountGT1;
    HGT1 = -nansum((oneCountGT1/totalCountGT1) * log(oneCountGT1/totalCountGT1)) -nansum((twoCountGT1/totalCountGT1) * log(twoCountGT1/totalCountGT1)) -nansum((threeCountGT1/totalCountGT1) * log(threeCountGT1/totalCountGT1));
    tempIG1 = HS - ((totalCountLTE1/size(train,1)) * HLTE1 + (totalCountGT1/size(train,1)) * HGT1);%these are being treated as nan
       
    totalCountLTE2 = oneCountLTE2+twoCountLTE2+threeCountLTE2;
    HLTE2 = -nansum((oneCountLTE2/totalCountLTE2) * log(oneCountLTE2/totalCountLTE2)) -nansum((twoCountLTE2/totalCountLTE2) * log(twoCountLTE2/totalCountLTE2)) -nansum((threeCountLTE2/totalCountLTE2) * log(threeCountLTE2/totalCountLTE2));
        
    totalCountGT2 = oneCountGT2+twoCountGT2+threeCountGT2;
    HGT2 = -nansum((oneCountGT2/totalCountGT2) * log(oneCountGT2/totalCountGT2)) -nansum((twoCountGT2/totalCountGT2) * log(twoCountGT2/totalCountGT2)) -nansum((threeCountGT2/totalCountGT2) * log(threeCountGT2/totalCountGT2));
    tempIG2 = HS - ((totalCountLTE2/size(train,1)) * HLTE2 + (totalCountGT2/size(train,1)) * HGT2);
        
        
    totalCountLTE3 = oneCountLTE3+twoCountLTE3+threeCountLTE3;
    HLTE3 = -nansum((oneCountLTE3/totalCountLTE3) * log(oneCountLTE3/totalCountLTE3)) -nansum((twoCountLTE3/totalCountLTE3) * log(twoCountLTE3/totalCountLTE3)) -nansum((threeCountLTE3/totalCountLTE3) * log(threeCountLTE3/totalCountLTE3));
       
    totalCountGT3 = oneCountGT3+twoCountGT3+threeCountGT3;
    HGT3 = -nansum((oneCountGT3/totalCountGT3) * log(oneCountGT3/totalCountGT3)) -nansum((twoCountGT3/totalCountGT3) * log(twoCountGT3/totalCountGT3)) -nansum((threeCountGT3/totalCountGT3) * log(threeCountGT3/totalCountGT3));
    tempIG3 = HS - ((totalCountLTE3/size(train,1)) * HLTE3 + (totalCountGT3/size(train,1)) * HGT3);
        
    totalCountLTE4 = oneCountLTE4+twoCountLTE4+threeCountLTE4;
    HLTE4 = -nansum((oneCountLTE4/totalCountLTE4) * log(oneCountLTE4/totalCountLTE4)) -nansum((twoCountLTE4/totalCountLTE4) * log(twoCountLTE4/totalCountLTE4)) -nansum((threeCountLTE4/totalCountLTE4) * log(threeCountLTE4/totalCountLTE4));
       
    totalCountGT4 = oneCountGT4+twoCountGT4+threeCountGT4;
    HGT4 = -nansum((oneCountGT4/totalCountGT4) * log(oneCountGT4/totalCountGT4)) -nansum((twoCountGT4/totalCountGT4) * log(twoCountGT4/totalCountGT4)) -nansum((threeCountGT4/totalCountGT4) * log(threeCountGT4/totalCountGT4));
    tempIG4 = HS - ((totalCountLTE4/size(train,1)) * HLTE4 + (totalCountGT4/size(train,1)) * HGT4);
    
    [maxTempIG, loc] = max([tempIG1; tempIG2; tempIG3; tempIG4]); %max temp IG is NaN after initial split
       
    if(maxTempIG > IG(1)) %save it
        if(loc == 1)
            IG = [maxTempIG; i; 1;];
        elseif(loc == 2)
            IG = [maxTempIG; i; 2;];
        elseif(loc == 3)
            IG = [maxTempIG; i; 3;];
        elseif(loc == 4)
            IG = [maxTempIG; i; 4;];
        end
    end
end

IG

train

%At this point we have the value to get the max IG (theoretically)

%report the split rule and other data
fprintf('Split rule:    Feature %d <= %f\nNumber of data points: %d\n\n', IG(3), train(IG(2),IG(3)), size(train, 1));

%split it and call split with the splitted data
LTE = [];
GT = [];

for k=1:size(train,1)
    if(train(k,IG(3)) <= train(IG(2),IG(3)))
        LTE = [LTE; train(k, :);];
    else
        GT = [GT; train(k,:);];
    end
end

if(size(LTE,1) >= 1)
    Split(LTE);
end
if(size(GT,1)>=1)
    Split(GT);
end

else
    train
    fprintf('Pure Node:    Label %d\nNumber of data Points: %d\n\n', train(1,5), size(train,1)); %might have nothing in the pure node
end

%remove all instances of 
%recheck to see if we have a pure node, update the boolean to check if we do
end