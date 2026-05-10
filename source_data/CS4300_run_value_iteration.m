function [S,A,R,P,U,Ut] = CS4300_run_value_iteration(gamma,max_iter)
% CS4300_run_value_iteration - this function is the driver function of
%                               the value iteration function
% On input:
%       gamma (double): discount value
%       max_iter (int): maximum iteration
% On output:
%       [S,A,R,P,U,Ut]:
%           S (vector): states (1 to 16)
%           A (vector): actions (1 to 4)
%           R (vector): state rewards
%           P (nxk struct array): transition model
%               (s,a).probs (a vector with n transition probabilities
%               (from s to s_prime, given action a)
%           U (vector): state utilities
%           U_trace (iterxn): trace of utility values during iteration
% Call:
%       [S,A,R,P,U,Ut] = CS4300_run_value_iteration(0.9,1000);
% Author:
%       Haochen Zhang & Tim Wei
%       UU
%       Fall 2017
%
S = 1:16;
A = 1:4;
P = transition_probability_table;
R = -ones(4);
R(:,3) = -1000*ones(1,4);
R(1,3) = -1;
R(1,4) = 1000;
R = [R(4,:),R(3,:),R(2,:),R(1,:)];
[U,Ut] = CS4300_MDP_value_iteration(S,A,P,R,gamma,0.1,max_iter);