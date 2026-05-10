clear all;
clc;
st=5;
PI=pi;
phiqdata=xlsread('C:\Users\Baktha\Desktop\Personal\sampleData.xlsx');
k=1;
for i=1:2:143
    PHIp(:,k)=phiqdata(:,i);
    Qp(:,k)=phiqdata(:,i+1);
    Np(:,k)=(phiqdata(:,i+1))/2;
    k=k+1;
end

wind=72;
samp=30;
%----------------------------%

tot=wind*samp; % total no of phi, q sets
z=0;
ex = 18;
data=phiqdata;
testdata(1:samp,:) = phiqdata(1:samp,:);
w(1,:) = data(1,:);
w(2,:)= data(3,:);
w(3,:) = data(5,:);
w(4,:)= data(6,:);
w(5,:) = data(8,:);
w(6,:) = data(10,:);
w(7,:)= data(11,:);
w(8,:)= data(13,:);
w(9,:) = data(15,:);
w(10,:) = data(16,:);
w(11,:) = data(18,:);
w(12,:) = data(20,:);
w(13,:) = data(21,:);
w(14,:) = data(23,:);
w(15,:) = data(25,:);
w(16,:) = data(26,:);
w(17,:) = data(28,:);
w(18,:) = data(30,:);

% State assignment by comparing the given data with the exemplar data and
% deciding on a particular state using minimum distance method.
ex=18;
samp=30;

for m=1:18
    l=1;d=1;
    for n=1:144
        w1(m,l,d)=w(m,n);
        d=d+1;
        if d==3
            d=1;
            l=l+1;
        end
    end
end


for m=1:18
    for x=1:2
        for y=1:72
            o(x,y)=w1(m,y,x);
        end
    end
for j=samp-ex+1:samp
    for i=1:samp-ex
        k(i)=(sqrt((o(1,j)-o(1,i))^2+(o(2,j)-o(2,i))^2+(o(3,j)-o(3,i))^2));
    end
    [tem, index]=min(k);
    count(j)=index;
end
for j=samp-ex+1:samp
    cnt=0;
    sum0=zeros(2,samp);
    sum0(:,j)=0;
    for i=1:4
        if(count(j)==i)
            sum0(:,j)=sum0(:,j)+o(:,i);
            cnt=cnt+1;
        end
    end
    sum0(:,j)=sum0(:,j)+o(:,j);
    c(:,j)=sum0(:,j)/(cnt+1);
end
b=zeros(N,T);
for i=samp-ex+1:samp
    b(:,i-(samp-ex))=c(:,i);
end
clear c;
c=b;
for i=1:N
    st(:,i)=c(:,i);
end
count=0;
flag=0;
I=zeros(N,T);
cnt=0;
while(flag==0)
    stprev=st;
    d=zeros(N,T);
    for i=1:N
        dd=zeros(1,T);
        for j=1:T
            for k=1:3
                dd(1,j)=dd(1,j)+(st(k,i)-c(k,j))^2;
            end
            d(i,j)=sqrt(dd(1,j));
        end
    end
    
    Iprev=I;
    I=zeros(N,T);
    for i=1:T
        [temp,index]=min(d(:,i));
        I(index,i)=1;
    end
    if(Iprev==I)
        flag=1;
    end
    for i=1:N
        stt(:,i)=zeros(N,1);
        count=0;
        for j=1:T
            if(I(i,j)==1)
                stt(:,i)=stt(:,i)+c(:,j);
                count=count+1;
            end
        end
        st(:,i)=stt(:,i)/count;
    end
    %     if(stprev==st)
    %         flag=1;
    %     end
    cnt=cnt+1
end

for j=1:T
    for i=1:N
        if(I(i,j)==1)
            s1(j)=i;
        end
    end
end
%-----------------------------------------------%
% Use the assigned states to find the Initial State Matrix

ex=18;
N=st;
wind=72;
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

% here the first state is always 1, in case of our data, so the pi matrix
% will be[1,0,0,0,0]

%use the states to find the State Transition matrix
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
%the transitions are either to a particular state itself or to the next one

% 
% % B calculation
% 
% for p=1:ex
%     for j=1:wind
%         sym(:,p,j)=[w(p,2*j-1);w(p,2*j)];
%     end
% end
% for i=1:N
%     k=0;
%     sum0=0;
%     for m=1:ex
%         for n=1:wind
%             if(S(m,n)==i)
%                 sum0=sum0+sym(:,m,n);
%                 k=k+1;
%             end
%         end
%     end
%     meanofstate(:,i)=sum0/k;
% end
% 
% clear temp temp3 temp1
% for l=1:st
%     temp=0;temp1=0;
%     for i=1:ex
%         for j=1:wind
%             if S(i,j)==l
%                 temp3(1,:)=g1(i,j,:);
%                 temp=temp+((((temp3(1,:))'-meanofstate(:,l)))*((temp3(1,:))'-meanofstate(:,l))');
%                 temp1=temp1+1;
%             end
%         end
%     end
%     cv(l,:,:)=temp/temp1;
% end
% 
% dim=2;cou=0;
% clear temp temp1 temp2 temp3
% for i=1:ex
%     for jj=1:st
%         if(jj~=3 && jj~=4)
%             temp(:,:)=cv(jj,:,:);
%             temp1=(det(temp))^0.5;
%             for k=1:wind
%                 temp2(1,:)=g1(i,k,:);
%                 temp3=inv(temp);
%                 if det(temp)==0
%                     cou=cou+1;
%                 end
%                 B(i,jj,k)=((1/(((2*pi)^(dim/2))*temp1))*exp(-0.5*(temp2'-meanofstate(:,jj))'*(temp3)*((temp2'-meanofstate(:,jj)))));
%                 check=((1/(((2*pi)^(dim/2))*temp1))*exp(-0.5*(temp2'-meanofstate(:,jj))'*(temp3)*((temp2'-meanofstate(:,jj)))));
%             end
%         end 
%     end
% end
% clear b;
% a=A;
% b(:,:)=B(1,:,:);


% Modified Model for B---> without using mean or covariance, by using the
% assigned states alone to find the probability density and make it
% suitable for HMM
b=zeros(18,5,72);
for i=1:18
    for k=1:N
        sum0(i,k)=0;
        for j=1:72
            if S(i,j)==k
                sum0(i,k)=sum0(i,k)+1;
            end
        end
    end
end

for i=1:18
    j=1;
    for k=1:N
        s=sum0(i,k);
        while s~=0
            b(i,k,j)=sum0(i,k)/72;
            j=j+1;
            s=s-1;
        end
    end
end

% Put a loop from this stmt onwards to edit
b1(:,:)=b(1,:,:);   % this to iterate it for N number of times
aa=sum(b1,2);   
for i=1:5
    b2(i,:)=b1(i,:)/aa(i);
end
B=b2;

clear b;
b=B;
a=A;
N =st ;
K = 72;
sum0=0;
Ob= sort(randi(72,1,72));
sort(Ob);

T=length(Ob);
Beta=zeros(T,N);
Alpha=zeros(T,N);
i=0;
j=0;
t=0;
ZI=zeros(T,N,N);
nu=0.0;
Gamma=zeros(T,N);
E_T=zeros(1,N);
E_I_J=zeros(1,N);
E_Pi=zeros(1,N);
E_A=zeros(N,N);
N_E_A=zeros(N,N);
E_B=zeros(N,K);
sum1=zeros(K);
p_v=zeros(N);
status=zeros(1,N);
m=0;
n=0;
tt=0;

%Forward Algorithm
for i=1:N
    Alpha(1,i)=Pi(i) * b(i,Ob(1));
end

for t=1:T-1
    for j=1:N
        sum0=0;
        for i=1:N
            sum0= sum0+ Alpha(t,i)*a(i,j);
        end
        Alpha(t+1,j)=sum0 * b(j,Ob(t+1));
    end
end
disp('The forward matrix is:');

for i=1:T
    for j=1:N
        fprintf('%.8f',Alpha(i,j));
        fprintf('    ');
    end
    fprintf('\n');
end
fprintf('\n');

%Backward Algorithm
for i=1:N
    Beta(T,i)=1;
end

for t=T-1:-1:1
    for i=1:N
        sum0=0;
        for j=1:N
            sum0=sum0+(a(i,j)*Beta(t+1,j)*b(j,Ob(t+1)));
        end
        Beta(t,i)=sum0;
    end
end
disp('The backward matrix is:');

for i=1:T
    for j=1:N
        fprintf('%.8f',Beta(i,j));
        fprintf('    ');
    end
    fprintf('\n');
end
fprintf('\n');

%Baum-Welch Algorithm
kk=0;
sum2=0;
%Calculation of ZI values
for t=1:T-1
    for i=1:N
        for j=1:N
            nu=Alpha(t,i)*b(j,Ob(t+1))*Beta(t+1,j)*a(i,j);
            sum0=0;
            for m=1:N
                for n=1:N
                    sum0 = sum0 + (Alpha(t,m) *a(m,n) *b(n,Ob(t+1)) *Beta(t+1,n));
                end
            end
            ZI(t,i,j) = nu/sum0;
        end
    end
end
% disp('The ZI matrix is:');
% disp(ZI);

%Gamma computation
for t=1:T
    for i=1:N
        sum0=0;
        for j=1:N
            sum0 = sum0+ZI(t,i,j);
        end
        Gamma(t,i)=sum0;
    end
end
disp('The Gamma matrix is:');
for i=1:T
    for j=1:N
        fprintf('%.8f',Gamma(i,j));
        fprintf('    ');
    end
    fprintf('\n');
end
fprintf('\n');

%Expected number of transistions from state i
for i=1:N
    sum0=0;
    for t=1:T-1
        sum0= sum0 + Gamma(t,i);
    end
    E_T(i)=sum0;
end
disp('Expected no of transitions from the states:');
for i=1:N
    fprintf('%.4f',E_T(i));
    fprintf('\n');
end

%Expected number of transitions from node i to node j
for i=1:N
    for j=1:N
        sum0=0;
        for t=1:T-1
            sum0= sum0+ZI(t,i,j);
        end
        E_I_J(i)=sum0;                   % may be a mistake (already mentioned in the C version)..............
        fprintf('Expected no of transitions from the state %d to state %d:', i,j);
        fprintf('%.4f \n',E_T(i));
    end
end

%Computing estimated values for Pi ,A and B.
for i=1:N
    E_Pi(i)= Gamma(1,i);    % E_Pi(i)= Gamma(0,(i));
end

for i=1:N
    for j=1:N
        sum0=0;
        nu=0;
        for t=1:T-1
            sum0=sum0+ZI(t,i,j);
            nu=nu+Gamma(t,i);
        end
        E_A(i,j) = (sum0 / nu)  ;
    end
end
disp('The estimated state transition matrix is:');
for i=1:N
    for j=1:N
        fprintf('%.8f',E_A(i,j));
        fprintf('    ');
    end
    fprintf('\n');
end
fprintf('\n');

%Computing the matrix B
for j=1:N     % number of states
    sum2=0;
    for kk=1:K
        sum1(kk)=0;
    end
    for t=1:T  %to traverse the observation sequence...
        for kk=1:K
            if(Ob(t) == kk)  % here one for loop will come
                sum2 = sum2+ Gamma(t,j); % overall sum ..........
                sum1(kk)= sum1(kk) + Gamma(t,j);
                break;
            end
        end
    end
    for kk=1:K
        E_B(j,kk) = (sum1(kk))/sum2;
    end
end

disp('The estimated probability matrix is:');
for i=1:N
    for j=1:K
        fprintf('%.8f',E_B(i,j));
        fprintf('    ');
    end
    fprintf('\n');
end
fprintf('\n');


%probability of visit
sum0 = 0;
%disp(' The probability of the node being visited during the training phase');
%disp(N);
for i=1:N
    if(i==1)
        p_v(i)=E_Pi(i);
    else
        sum0=0;
        for j=1:(i-1)
            sum0= sum0 + p_v(j)*(E_A(j,i)/(1-E_A(j,j)) );
        end
    end
    p_v(i)= sum0 + (E_Pi(i));
end

tt=1;
for i=1:N
    if(p_v(i)*100 >= 40.0)
        status(tt)=i;
        tt= tt +1;
    else
        status(i)=0;
    end
end
disp('The status during the transition is:');
disp(status);
fprintf('\n');

%Normalization
sum2 = 0;
sum3 = 0;
pp = 0;
pp1 = 0;
for i=1:N
    if(i==status(pp+1)) % status(pp)
        pp=pp+1;
        for j=1:N
            N_E_A(i,j)=E_A(i,j);
        end
    else
        sum3=0;
        sum2=0;
        pp1=0;
        for j=1:N
            if(j==status(pp1+1)) %status(pp1)
                pp1=pp1+1;
                sum3= sum3 + a(i,j);
            else
                sum2= sum2 + E_A(i,j);
            end
        end
        
        pp1=0;
        for j=1:N
            if(j~=status(pp1+1))  %status(pp1)
                N_E_A(i,j)=(1-sum3)*(E_A(i,j)/sum2);
            else
                pp1=pp1+1;
                N_E_A(i,j)=a(i,j);
            end
        end
    end
end
disp('After Normalization:');
fprintf('\n');
disp('The estimated state transition matrix is:');
for i=1:N
    for j=1:N
        fprintf('%.8f',E_A(i,j));
        fprintf('    ');
    end
    fprintf('\n');
end
fprintf('\n');
disp('The estimated probability matrix is:');
for i=1:N
    for j=1:K
        fprintf('%.8f',E_B(i,j));
        fprintf('    ');
    end
    fprintf('\n');
end

