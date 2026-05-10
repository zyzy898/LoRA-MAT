function U = CS4300_run_policy_4x3()
% CS4300_MDP_policy - a driver function for CS4300_MDP_policy_iteration
%               runs in the following 4 × 3 world, calculated with 
%               gamma = 1 and R(s) = -0.04 for nonterminal states.
%
%                   0 0 0 +1
%                   0 x 0 -1
%                   0 0 0  0
%
% On output:
%       U (3x4 double): state utilities
% Call:
%       U = CS4300_run_policy_4x3()
% Author:
%       Haochen Zhang & Tim Wei
%       UU
%       Fall 2017
%

S = 1:12;
A = 1:4;
P = transition_probability_table_4x3;
R = ones(12,1) * -0.04;
R(12) = 1;
R(8) = -1;
[p,U,Ut] = CS4300_MDP_policy_iteration(S,A,P,R,10000,1);
U = U';
U = [U(9:12);U(5:8);U(1:4)];
p = p';
p = [p(9:12);p(5:8);p(1:4)];