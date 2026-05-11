 %prim O(n^2)
A = [0 2 1 4 inf;2 0 inf 4 inf; 1 inf 0 3 inf;4 4 3 0 1; inf inf inf 1 0];
 n = size(A,2);
 pairs = zeros( n-1,2);
 adj = zeros(size(A));
 visited = logical( [ 1 zeros(1,n-1)]); %we will visit the first one
 counter = 1;
 
while pairs(size(pairs,1),1) == 0 % visited all nodes
    min = inf;
     for i = 1:n
         if(visited(1,i))
             for j = 1 : n       
                 if(~visited(1,j) && min > A(i,j))
                     min = A(i,j)               
                     pairs(counter,:) = [ i j ]  ;            
                 end
             end
         end    
     end
     visited(1,pairs(counter,2)) = true;
     adj(pairs(counter,1),pairs(counter,2)) = A(pairs(counter,1),pairs(counter,2));
     adj(pairs(counter,2),pairs(counter,1)) = A(pairs(counter,2),pairs(counter,1));
     counter = counter +1;
end