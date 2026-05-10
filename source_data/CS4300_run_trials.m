function trials = CS4300_run_trials(max_steps)
% CS4300_run_trials - trails runner
% It runs 2000 trials to analyze the behavior of a random agent 
% On input:
%     max_steps (int): maximum number of steps allowed
% On output:
%     report (report data structure): values needed for the report
%       gold (double): the percentage of times the agent arrives at square [2, 2].
%       mean (double): the mean of the number of steps the agent survives
%       variance (double): the variance of the number of steps the agent survives
%       ci (double): the 95% confidence interval
% Call:
%     report = CS4300_report(50);
% Author:
% Tim Wei, Haochen Zhang
% UU
% Fall 2017
%

trialnum = 2000;  % number of trials 

trials.gold = 0;  % the percentage of times the agent arrives at square [2, 2].
trials.mean = 0;  % the mean of the number of steps the agent survives
trials.variance = 0;  % the variance of the number of steps the agent survives
trials.ci = 0;  % the 95% confidence interval, the actual ci is mean +- return value

arr_steps = zeros(1,trialnum);  % generate an array to store the steps for each trial
totle_steps = 0;  % store the totle steps

for i = 1:trialnum
    t = CS4300_WW2(max_steps,'CS4300_agent1');
    
    for it = t
        if it.agent.x == 2 && it.agent.y == 2
            trials.gold = trials.gold + 1;  % once reach the gold cell, record and bread the loop
            break;
        end
    end
    
    %{
    for it = t
        if it.agent.alive == 1
            arr_steps(i) = arr_steps(i) + 1;
        end
    end
    %}
    % Better way to record stpes for each trial
    arr_steps(i) = length(t);
    if t(end).agent.alive ~= 1
        arr_steps(i) = arr_steps(i) - 1;
    end
    
    totle_steps = totle_steps + arr_steps(i);
end

%{
report.mean = totle_steps / trialnum;

for i = 1:trialnum
    report.variance = report.variance + (arr_steps(i) - report.mean) ^ 2;
end
report.variance = report.variance / trialnum;
%}
% Better way to calculate mean and variance
trials.mean = mean(arr_steps);
trials.variance = var(arr_steps);

trials.ci = sqrt(trials.variance / trialnum) * 1.960;

trials.gold = (trials.gold / trialnum) * 100;