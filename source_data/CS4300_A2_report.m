function report = CS4300_A2_report()

trialnum = 2000;  % number of trials 
max_steps = 1000;
for i = 1:2
    for j = 1:3
        report(i,j).survive = 0;
        report(i,j).mean = 0;
        report(i,j).var = 0;
        report(i,j).ci = 0;
        temp(i,j).steps = [];
    end
end
board = [0,0,0,2;0,0,0,0;0,0,1,0;0,0,1,0];
for i = 1:trialnum
    clear CS4300_agent_Astar;
    t = CS4300_WW2(max_steps, 'CS4300_agent_Astar', board);
    
    if t(end).agent.succeed
        report(1,1).survive = report(1,1).survive + 1;
        temp(1,1).steps = [temp(1,1).steps; length(t)];
    end
    clear CS4300_agent_Astar_AC;
    t = CS4300_WW2(max_steps, 'CS4300_agent_Astar_AC', board);
    
    if t(end).agent.succeed
        report(2,1).survive = report(2,1).survive + 1;
        temp(2,1).steps = [temp(2,1).steps; length(t)];
    end
end
board = [1,0,2,0;0,0,0,0;0,0,1,0;0,0,0,1];
for i = 1:trialnum
    clear CS4300_agent_Astar;
    t = CS4300_WW2(max_steps, 'CS4300_agent_Astar', board);
    
    if t(end).agent.succeed
        report(1,2).survive = report(1,2).survive + 1;
        temp(1,2).steps = [temp(1,2).steps; length(t)];
    end
    clear CS4300_agent_Astar_AC;
    t = CS4300_WW2(max_steps, 'CS4300_agent_Astar_AC', board);
    
    if t(end).agent.succeed
        report(2,2).survive = report(2,2).survive + 1;
        temp(2,2).steps = [temp(2,2).steps; length(t)];
    end
end
board = [0,0,0,2;1,1,0,0;0,0,0,1;0,0,0,0];
for i = 1:trialnum
    clear CS4300_agent_Astar;
    t = CS4300_WW2(max_steps, 'CS4300_agent_Astar', board);
    
    if t(end).agent.succeed
        report(1,3).survive = report(1,3).survive + 1;
        temp(1,3).steps = [temp(1,3).steps; length(t)];
    end
    clear CS4300_agent_Astar_AC;
    t = CS4300_WW2(max_steps, 'CS4300_agent_Astar_AC', board);
    
    if t(end).agent.succeed
        report(2,3).survive = report(2,3).survive + 1;
        temp(2,3).steps = [temp(2,3).steps; length(t)];
    end
end
for i = 1:2
    for j = 1:3
        report(i,j).mean = mean(temp(i,j).steps);
        report(i,j).var = var(temp(i,j).steps);
        report(i,j).ci = sqrt(report(i,j).var / report(i,j).survive) * 1.960;
        report(i,j).survive = report(i,j).survive / trialnum;
    end
end