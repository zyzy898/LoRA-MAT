function [policy,U,Ut] = CS4300_MDP_policy_iteration(S,A,P,R,k,gamma)
% CS4300_MDP_policy_iteration - policy iteration
%  Chapter 17 Russell and Norvig (Table p. 657)
% On input:
%     S (vector): states (1 to n)
%     A (vector): actions (1 to k)
%     P (nxk array): transition model
%     R (vector): state rewards
%     k (int): number of iterations
%     gamma (float): discount factor
% On output:
%     policy (nx1 vector): policy for problem
%     U (nx1 vector): final utilities found
%     Ut (num_iter by n array): trace of utilities (each is U at that step)
% Call:
% 
%     Layout:           1
%    13 14 15 16        ˆ
%     9 10 11 12        |
%     5  6  7  8    2 <- -> 4
%     1  2  3  4        |
%                       V
%                       3
%     [S,A,R,P] = CS4300_MDP_policy_iteration_args();
%     [p,Up,Tpt] = CS4300_MDP_policy_iteration(S,A,P,R,10,0.999)
%     p’
% 
% p =
% 
%      1         corrresponds to:
%      2                >    >    ^    G
%      2                ^    <    x    >
%      4                ^    <    x    >
%      1                ^    <    x    >
%      2
%      2
%      4
%      1
%      2
%      2
%      4
%      4
%      4
%      1
%      4
% 
% Author:
%     Haochen Zhang & Tim Wei
%     UU
%     Fall 2017
% 

policy = randi(length(A),length(S),1);
U = zeros(length(S),1);
Ut = [U];

for i = 1:k
    U = CS4300_policy_evaluation(S,P,R,U,policy,gamma);
    Ut = [Ut,U];
    unchanged = 1;
    [temp_policy,max_U] = CS4300_MDP_policy(S,A,P,U);
    for j = S
        if max_U(j) > sum(P(j,policy(j)).probs.*U)
            if policy(j) ~= temp_policy(j)
                policy(j) = temp_policy(j);
                unchanged = 0;
            end
        end
    end
    if unchanged
        break;
    end
end
