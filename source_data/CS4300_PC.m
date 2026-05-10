function D_revised = CS4300_PC(G,D,P)
% CS4300_PC - a PC function from Mackworth paper 1977
% On input:
%       G (nxn array): neighborhood graph for n nodes
%       D (nxm array): m domain values for each of n nodes
%       P (string): predicate function name; P(i,a,j,b) takes as
% arguments:
%       i (int): start node index
%       a (int): start node domain value
%       j (int): end node index
%       b (int): end node domain value
% On output:
%       D_revised (nxm array): revised domain labels
% Call:
%       G = 1 - eye(3,3);
%       D = [1,1,1;1,1,1;1,1,1];
%       Dr = CS4300_PC(G,D,’CS4300_P_no_attack’);
% Author:
%       Tim Wei, Haochen Zhang
%       UU
%       Fall 2017
%

% n = 16, m = 3
n = length(G);
m = length(D(1,:));

% Initialize the matrix
for i = 1:n
    for j = 1:n
        % Diagonal of the matrix
        if i == j
            R(i,j).R = eye(m,m);
        % Neighboring cell
        elseif G(i,j)
            R(i,j).R = zeros(m,m);
            
            % Initialize 3x3 using predicate
            for a = 1:m
                for b = 1:m
                    R(i,j).R(a,b) = feval(P,i,a,j,b);
                end
            end
            
        % Everything is possible for cells that are not neighbors
        else
            R(i,j).R = ones(m,m);
        end
    end
end

% Set all values to 0 for cells that have 0 in that percept in D
for i = 1:n
    for j = 1:m
        if ~D(i,j)
            for k = 1:n
                R(i,k).R(j,:) = zeros(1,3);
            end
        end
    end
end

% Check path consistency
Y(n+1).R = R;
while 1
    Y(1) = Y(end);
    done = 1;
    for k = 1:n
        for i = 1:n
            for j = 1:n
                ik = double(Y(k).R(i,k).R) * double(Y(k).R(k,k).R);
                ij = ik * double(Y(k).R(k,j).R);
                Y(k+1).R(i,j).R = Y(k).R(i,j).R & (ij > 0);
                if k == n
                    done = done & all(all(Y(n).R(i,j).R == Y(1).R(i,j).R));
                end
            end
        end
    end
    if done
        break;
    end
end

% Put it back to D and return 
D_revised = zeros(16,3);
for i = 1:n
    for j = 1:m
        if Y(1).R(i,i).R(j,j)
            D_revised(i,j) = 1;
        end
    end
end
