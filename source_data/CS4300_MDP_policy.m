function [policy,max_U] = CS4300_MDP_policy(S,A,P,U)
% CS4300_MDP_policy - generate a policy from utilities
% See p. 648 Russell & Norvig
% On input:
%       S (vector): states (1 to n)
%       A (vector): actions (1 to k)
%       P (nxk struct array): transition model
%         (s,a).probs (a vector with n transition probabilities
%         from s to s_prime, given action a)
%       U (vector): state utilities
% On output:
%       policy (vector): actions per state
%       max_U (vector): the expected utilities calculated by policy
% Call:
%       p = CS4300_MDP_policy(S,A,P,U);
% Author:
%       Haochen Zhang & Tim Wei
%       UU
%       Fall 2017
%

len_A = length(A);
len_S = length(S);
policy = zeros(len_S,1);
max_U = -int32(ones(len_S,1)) * intmax;

for i = 1:len_S
    for j = 1:len_A
        U_prime = sum(P(i,j).probs.*U);
        if (max_U(i) <= U_prime)
            max_U(i) = U_prime;
            policy(i) = j;
        end
    end
end