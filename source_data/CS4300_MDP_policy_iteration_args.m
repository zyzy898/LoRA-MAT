function [S,A,R,P] = CS4300_MDP_policy_iteration_args()
% CS4300_MDP_policy_iteration_args - prepares the arguments for 
%                                       CS4300_MDP_policy_iteration
% On output:
%     S (vector): states (1 to n)
%     A (vector): actions (1 to k)
%     P (nxk array): transition model
%     R (vector): state rewards
% Call:
%     [S,A,R,P] = CS4300_MDP_policy_iteration_args();
% Author:
%     Haochen Zhang & Tim Wei
%     UU
%     Fall 2017
% 
S = 1:16;
A = 1:4;
P = transition_probability_table;
R = -ones(4);
R(2,3) = -1000;
R(3,3) = -1000;
R(4,3) = -1000;
R(1,4) = 1000;
R = [R(4,:),R(3,:),R(2,:),R(1,:)];