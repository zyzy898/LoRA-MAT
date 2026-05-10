clear all;
clc;

for iii=3:9
    clearvars -except iii
    fileno=strcat('00',num2str(iii));
    % phiqdata=xlsread(strcat('J:\Universita di Bologna\Papers for modification in code\venkatesh sir 4 feb files\data of epoxy double v\epoxy void_ac test.',fileno,'PQNDATA.xlsx'));
    
    %fileno='001';
    filename1=strcat('J:\Datasets\Corona\CoronaFile',fileno);
    data=xlsread(strcat(filename1,'-PQNTIdata.xlsx'));
    siz=size(data);
    row=siz(1);
    col=siz(2);
    k=1;
    for i=1:4:72*4-3
        phi(:,k)=data(:,i);
        q(:,k)=data(:,i+1);
        k=k+1;
    end
    
    m=1;
    if row<30
        for k=1:72
            qsu(m,k)=0;
            qav(m,k)=0;
            n(m,k)=0;
            for j=i:size(data,1)
                qsu(m,k)=qsu(m,k)+(q(j,k));
                if(q(j,k)~=0)
                    n(m,k)=n(m,k)+1;
                end
            end
            qav(m,k)=qsu(m,k)/size(data,1);
        end
        m=m+1;
    else
        for i=1:floor(row/30):row
            for k=1:72
                qsu(m,k)=0;
                qav(m,k)=0;
                n(m,k)=0;
                for j=i:i+floor(row/30)-1
                    qsu(m,k)=qsu(m,k)+(q(j,k));
                    if(q(j,k)~=0)
                        n(m,k)=n(m,k)+1;
                    end
                end
                qav(m,k)=qsu(m,k)/ floor(row/30);
            end
            m=m+1;
        end
    end
    for i=1:size(qav,1) % for i=1:30
        for j=1:72
            combinedfinal(i,(3*j)-2)=phi(1,j);
            combinedfinal(i,(3*j)-1)=qav(i,j);
            combinedfinal(i,(3*j))=n(i,j);
        end
    end
    xlswrite(strcat(filename1,'-PQNdataCorrectedNQavg30equaldata.xlsx'),combinedfinal);
end