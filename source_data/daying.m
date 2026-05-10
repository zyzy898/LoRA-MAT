function [y,yy]=daying(x,rice,noodles,ricedishes,nooddishes,soup,ricedata,...
    soupingre,riceingre,znood)
he=1;bj=1;
while size(he,2)+sum(bj)~=5
    y=zeros(rice+noodles,5);
    y(1:noodles,1)=x(1:noodles);
    y(noodles+1:end,1)=size(ricedishes,2);
    y(1:noodles,2)=x(noodles+1:2*noodles)';
    y(noodles+1:end,2)=x(2*noodles+1:2*noodles+rice);
    ri=x(2*noodles+rice+1:end);
    ri=ri(ri>0);


    rou=ri(ricedata(ri(ri>0),24)==1);
    su=ri(ricedata(ri(ri>0),24)==2);
    chong=soupingre(y(noodles+1:end,2),:);

    numPercClass=1;
    while numPercClass>0
        roup=randperm(size(rou,2));
        sup=randperm(size(su,2));
        y(noodles+1:end,3)=rou(roup(1:rice));
        y(noodles+1:end,4)=su(sup(1:rice));
        for k=3:4
            chong=[chong riceingre(y(noodles+1:end,k),:)];
        end
        numPercClass = sum(sum(histc(chong',[1:100])>1));
        if numPercClass>=1
            chong=soupingre(y(noodles+1:end,2),:);
        end
    end
    he=[rou(roup(rice+1:end)) su(sup(rice+1:end))];
    bj=ones(1,5);
    for i=1:size(he,2)
        for j=noodles+1:noodles+rice
            if(bj(j)==0)
                continue
            end
            mt=[chong(j-noodles,:) riceingre(he(i),:)];
            numPercClass = sum(sum(histc(mt,[1:100])>1));
            if numPercClass>=1
                continue
            end
            y(j,5)=he(i);
            bj(j)=0;
            break
        end
    end
end
% for i=1:rice
% while 1
%      roup=randperm(size(rou,2));
%      sup=randperm(size(su,2));
%     y(noodles+1:end,3)=rou(roup(1:rice));
%     y(noodles+1:end,4)=su(sup(1:rice));
%     he=[rou(rice+1:end) su(rice+1:end)];
%     y(noodles+1:noodles+size(he,2),5)=he;
%     for k=3:4
%         chong=[chong riceingre(y(noodles+1:end,k),:)];
%     end
%     for k=1:rice
%         if(y(k,5)==0)
%             continue
%         end
%         chong
% end
yy=cell(rice+noodles,5);
for i=1:noodles
    for j=1:2
    if y(i,j)==0
        continue
    elseif j==1
        yy(i,j)=znood(y(i,j));
    else
        yy(i,j)=nooddishes(y(i,j));
    end
    end
end
    
for i=noodles+1:rice+noodles
    for j=1:5
        if y(i,j)==0
            continue
        end
        if j==2
            yy(i,j)=soup(y(i,j));
        else
            yy(i,j)=ricedishes(y(i,j));
        end
    end
end
if noodles+rice==5
if noodles==1
    y([1,3],:)=y([3,1],:);
    yy([1,3],:)=yy([3,1],:);
end
if noodles==2
    y([1,4],:)=y([4,1],:);
    yy([1,4],:)=yy([4,1],:);
end
end

