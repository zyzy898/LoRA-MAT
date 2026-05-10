function [w,per_cor,Se] = CS4300_logistic_learning(X,y,alpha,max_iter,rate)
%   CS4300_logistic_learning - find linear separating hyperplane
%       Eqn 18.8, p. 727 Russell and Norvig
%   On input:
%       X (nxm array): n independent variable samples each of length m
%       y (nx1 vector): dependent variable samples
%       alpha (float): learning rate
%       max_iter (int): max number of iterations
%       rate (Boolean): 1 use alpha = 1000/(1000+iter) else constant alpha
%   On output:
%       w ((m+1)x1 vector): weights for linear function
%       per_cor (kx1 array): trace of percentage correct with weight
%       Se (kx1 array): trace of squared error
%   Call:
%       [w,pc,Se] = CS4300_logistic_learning(X,y,0.1,10000,1);
%   Author:
%       Haochen Zhang & Tim Wei
%       UU
%       Fall 2017
%

% Initialize w
n = length(X(:,1));
m = length(X(1,:));
w = 0.02 * rand(m+1,1) - 0.01;
iter = 0;
counter = 1;
per_cor = [];
Se = [];
X = [ones(n,1) X];
% Run for x epoches
for i = 1: max_iter
    j = randi(n);
    y_ = y(j);
    x_ = X(j,:);
    if rate
        alpha = 1000/(1000 + iter);
    end

    h = 1/(1 + exp(-x_ * w));

    w = w + (alpha * (y_ - h) * h * (1 - h)) * x_';
    per_cor(counter) = sum(((X * w) > 0) == y)/n;

    err = y - (1./(1 + exp(-X * w)));
    Se(counter) = sum(err .* err)/n;

    counter = counter + 1;

    iter = iter + 1;
end
