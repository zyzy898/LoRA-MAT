%%%%%%%%%
Qamplnew=abs(Qnew);
% qsumnew=0;
% for j=1:ex
%     qsumnew=qsumnew+sum(Qamplnew(j,:));
% end

wind=72;
% qavgnew=qsumnew/counter1;
Qamplnew=abs(Qnew);
for j=1:ex
    for k=1:zz
        if max(Qamplnew(j,:)~=0)
            Qpmodnew(j,k)=Qnew(j,k)/max(Qamplnew(j,:));
        else
            Qpmodnew(j,k)=0;
        end
    end
end

%%%%%%%%%%%

for j=1:ex
    for i=1:72
        zz=0;
        for k=0:0.05:1
            zz=zz+1;
            if abs(Qpmodnew(j,i))>=k
                Observ(j,i)=zz;
            end
        end
    end
end
%%%%%%%%%%----------calc observ--%%%%%%%%%%%%
