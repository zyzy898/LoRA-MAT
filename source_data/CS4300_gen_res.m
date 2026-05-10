function res = CS4300_gen_res(max_max_steps)
% CS4300_gen_res - result generator
% Runs trials under varying max_steps (from 1 to max_max_steps)
% On input:
%     max_max_steps (int): the maximum number of maximum number of steps
%     allowed that will be interated to.
% On output:
%     res (nx4 int array): result of various max_steps
%       i: max_steps used in the trials
%       (i,1): the percentage of times the agent arrives at square [2, 2].
%       (i,2): the mean of the number of steps the agent survives
%       (i,3): the variance of the number of steps the agent survives
%       (i,4): the 95% confidence interval
% Call:
%     res = CS4300_gen_res(100)
% Author:
% Tim Wei, Haochen Zhang
% UU
% Fall 2017
%

res = zeros(max_max_steps,4);
for i = 1:max_max_steps
    r = CS4300_run_trials(i);
    res(i,:) = [r.gold, r.mean, r.variance, r.ci];
end