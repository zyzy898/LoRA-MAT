function [y1,y2] = crossPop(x1, x2,noodles,rice)
    %单点交叉
    
    n = numel(x1)-2*noodles-rice;% 算出米饭配菜的长度
    s1 = randi([1, n-1]);% 随机选出一个交叉点，n-1操作是因为如果选择最后一位，就相当于没有交叉
   
    
    
    y1 = [x1(1:s1+2*noodles+rice+1)  x2(s1+2*noodles+rice+2:end)];% 重组
    y2 = [x2(1:s1+2*noodles+rice+1)  x1(s1+2*noodles+rice+2:end)];% 重组
end
