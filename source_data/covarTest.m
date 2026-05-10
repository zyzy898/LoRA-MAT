% B calculation
o1=[6.6096;-0.2507;0.3602];
o2=[2.3209;-1.6724;0.7802];
o3=[0.6991;-4.2347;0.9186];
o4=[0.2213;0.2285;0.9594];
o5=[0.2607;-2.2482;0.9866];
o6=[-0.0273;-2.3789;0.9985];
o7=[-0.0553;-1.8583;0.9938];
o8=[-0.1139;3.2653;0.9812];
o9=[0.1383;-1.0925;0.9860];
o10=[-0.0002;-0.0305;0.9919];
O1=[o1,o2,o3,o4,o5,o6,o7,o8,o9,o10];
S(1,:) =[1,2,3,3,3,2];
S(2,:) =[1,3,2,2,3,3];
S(3,:) =[1,2,3,3,3,3];
S(4,:) =[1,2,2,3,3,3];
S(5,:) =[1,2,2,3,2,3];
S(6,:) =[1,2,2,3,3,3];
S(7,:) =[1,2,3,3,3,2];
S(8,:) =[1,2,3,3,3,3];

N=3;
wind=6;
ex=8;
for i=1:N
    pii(i)=0;
    pc(i)=0;
    for z=1:ex
        if(S(z,1)==i)
            pii(i)=pii(i)+1;
        end
    end
    Pi(i)=pii(i)/ex;
end
A=zeros(N);
AA=zeros(N);

for i=1:N
    for j=1:N
        AA(i,j)=0;
        for y=1:ex
            for x=1:wind-1
                if((S(y,x)==i)&&(S(y,(x+1))==j))
                    AA(i,j)=AA(i,j)+1;
                end
            end
        end
        te=sum(AA,2);
    end
    A(i,:)=AA(i,:)/te(i);
end



for p=1:ex
    for j=1:wind
        sym(:,p,j)=[w(p,2*j-1);w(p,2*j)];
    end
end
for i=1:N
    k=0;
    sum0=0;
    for m=1:ex
        for n=1:wind
            if(S(m,n)==i)
                sum0=sum0+sym(:,m,n);
                k=k+1;
            end
        end
    end
    meanofstate(:,i)=sum0/k;
end

clear temp temp3 temp1
for l=1:st
    temp=0;temp1=0;
    for i=1:ex
        for j=1:wind
            if S(i,j)==l
                temp3(1,:)=g1(i,j,:);
                temp=temp+((((temp3(1,:))'-meanofstate(:,l)))*((temp3(1,:))'-meanofstate(:,l))');
                temp1=temp1+1;
            end
        end
    end
    cv(l,:,:)=temp/temp1;
end

dim=2;cou=0;
clear temp temp1 temp2 temp3
for i=1:ex
    for jj=1:st
        if(jj~=3 && jj~=4)
            temp(:,:)=cv(jj,:,:);
            temp1=(det(temp))^0.5;
            for k=1:wind
                temp2(1,:)=g1(i,k,:);
                temp3=inv(temp);
                if det(temp)==0
                    cou=cou+1;
                end
                B(i,jj,k)=((1/(((2*pi)^(dim/2))*temp1))*exp(-0.5*(temp2'-meanofstate(:,jj))'*(temp3)*((temp2'-meanofstate(:,jj)))));
                check=((1/(((2*pi)^(dim/2))*temp1))*exp(-0.5*(temp2'-meanofstate(:,jj))'*(temp3)*((temp2'-meanofstate(:,jj)))));
            end
        end 
    end
end
clear b;
a=A;
b(:,:)=B(1,:,:);
