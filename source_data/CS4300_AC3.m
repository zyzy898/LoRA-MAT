function D_revised = CS4300_AC3(G,D,P)
% CS4300_AC3 - AC3 function from Mackworth paper 1977
% On input:
% G (nxn array): neighborhood graph for n nodes
% D (nxm array): m domain values for each of n nodes
% P (string): predicate function name; P(i,a,j,b) takes as
% arguments:
% i (int): start node index
% a (int): start node domain value
% j (int): end node index
% b (int): end node domain value
% On output:
% D_revised (nxm array): revised domain labels
% Call:
% G = 1 - eye(3,3);
% D = [1,1,1;1,1,1;1,1,1];
% Dr = CS4300_AC3(G,D,’CS4300_P_no_attack’);
% Author:
% Tim Wei, Haochen Zhang
% UU
% Fall 2017
%
worklist = [];
for x = 1:length(G)
    for y = 1:length(G)
        if G(x,y)
            worklist = [worklist; x,y];
        end
    end
end

[~,m] = size(D);
while 1
    arc = worklist(1,:);
    x = arc(1);
    y = arc(2);
    worklist(1,:) = [];
    
    % arc-reduce
    change = 0;
    for i = 1:m
        if D(x,i)
            for j = 1:m
                if D(y,j) && feval(P,x,i,y,j) 
                    break; 
                end
                if j == m
                    D(x,i) = 0;
                    change = 1;
                end
            end
        end
    end
    
    if change
        for z = 1:length(G)
            if G(x,z) && z ~= y
                worklist = [worklist; z,x];
            end
        end
    end
    if isempty(worklist)
        break;
    end
    D_revised = D;
end
