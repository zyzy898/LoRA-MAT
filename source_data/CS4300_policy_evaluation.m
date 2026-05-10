function Up = CS4300_policy_evaluation(S,P,R,U,policy,gamma)
% CS4300_policy_evaluation - policy evaluation
%  Chapter 17 Russell and Norvig (Table p. 657)
% On input:
%     S (vector): states (1 to n)
%     P (nxk array): transition model
%     R (vector): state rewards
%     U (nx1 vector): utilities of the current iteration
%     policy (nx1 vector): current policy
%     gamma (float): discount factor
% On output:
%     Up (nx1 vector): utilities of the next iteration
% Call:
% 
%     Layout:           1
%    13 14 15 16        ˆ
%     9 10 11 12        |
%     5  6  7  8    2 <- -> 4
%     1  2  3  4        |
%                       V
%                       3
%     Up = CS4300_policy_evaluation(S,P,R,U,policy,gamma);
%     
% Author:
%     Haochen Zhang & Tim Wei
%     UU
%     Fall 2017
% 

Up = [];
for i = 1:length(S)
    Up = [Up ;R(i) + gamma * sum(P(i,policy(i)).probs.*U)];
end