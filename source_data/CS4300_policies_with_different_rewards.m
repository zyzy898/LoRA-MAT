function [lower_limits, upper_limmits, policies, policies_s] ...
        = CS4300_policies_with_different_rewards()
% CS4300_policies_with_different_rewards - Generate policies with different
%                               reward values of a clear cell
% On input:
%
% On output:
%       [lower_limits, upper_limmits, policies, policies_s]:
%           lower_limits(int): the lower bound of reward of clear cells
%           upper_limmits(int): the upper bound of reward of clear cells
%           policies(4x4xn int): action chosen for each cell
%           policies_s(4x4xn string): string representation of policies
% Call:
%       [lower_limits, upper_limmits, policies, policies_s] ...
%        = CS4300_policies_with_different_rewards()
% Author:
%       Haochen Zhang & Tim Wei
%       UU
%       Fall 2017
%
    
S = 1:16;
A = 1:4;
P = transition_probability_table;
policies = [];
lower_limits = [];
upper_limmits = [];

for i = -2000:2000
    R = ones(4) * i;
    R(2,3) = -1000;
    R(3,3) = -1000;
    R(4,3) = -1000;
    R(1,4) = 1000;
    R = [R(4,:),R(3,:),R(2,:),R(1,:)];

    [p,Up,Tpt] = CS4300_MDP_policy_iteration(S,A,P,R,10000,0.999);
    policy = [p(13:16),p(9:12),p(5:8),p(1:4)].';
    policy(1,4) = -2;
    policy(2,3) = -1;
    policy(3,3) = -1;
    policy(4,3) = -1;
    if isempty(policies)
        policies = policy;
        continue;
    end
    
    isNew = 1;
    for j = 1:length(policies(1,1,:))
        if isequal(policies(:,:,j),policy)
            isNew = 0;
            break;
        end
    end
    if isNew
        policies(:,:,length(policies(1,1,:))+1) = policy;
        lower_limits = [lower_limits; i];
        upper_limmits = [upper_limmits; i - 1];
    end
end
policies_s = string([]);
for i = 1:length(policies(1,1,:))
    policy = string(policies(:,:,i));
    policy(policy == "1") = "^";
    policy(policy == "2") = "<";
    policy(policy == "3") = "v";
    policy(policy == "4") = ">";
    policy(policy == "-1") = "x";
    policy(policy == "-2") = "G";
    policies_s(:,:,i) = policy;
end