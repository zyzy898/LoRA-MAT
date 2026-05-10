function action = CS4300_MC_agent(percept,num_trials)
% CS4300_MC_agent - Monte Carlo agent with a few informal rules
% On input:
%        percept (1x5 Boolean vector): percept from Wumpus world
%           (1): stench
%           (2): breeze
%           (3): glitter
%           (4): bump
%           (5): scream
%       num_trials (int): number of trials for MC to run
% On output:
%       action (int): action to take
%           1: FORWARD
%           2: RIGHT
%           3: LEFT
%           4: GRAB
%           5: SHOOT
%           6: CLIMB
% Call:
%       a = CS4300_MC_agent(percept);
% Author:
%       Haochen Zhang & Tim Wei
%       UU
%       Fall 2017

persistent plan board agent visited have_arrow on_new
persistent breezes stench screamed pits_P Wumpus_P danger_P W_pos

if isempty(board)
    plan = [];
    board = ones(4,4);
    board(4,1) = 0;
    agent.x = 1;
    agent.y = 1;
    agent.dir = 0;
    visited = zeros(4,4);
    visited(4,1) = 1;
    have_arrow = 1;
    on_new = 1;
    breezes = -ones(4,4);
    stench = -ones(4,4);
    screamed = 0;
end

FORWARD = 1;
RIGHT = 2;
LEFT = 3;
GRAB = 4;
SHOOT = 5;
CLIMB = 6;

if percept(5)
    screamed = 1;
    neis = BR_Wumpus_neighbors(W_pos(1),W_pos(2));
    for i = 1:length(neis)
        n = neis(i,:);
        stench(4-n(2)+1,n(1)) = 1;
    end
end

% Update danger
if on_new || percept(5)
    % Update breezes and stench
    breezes(4-agent.y+1, agent.x) = percept(2);
    if stench(4-agent.y+1, agent.x) == -1
        stench(4-agent.y+1, agent.x) = percept(1);
    end

    % Update pits and Wumpus
    [pits_P,Wumpus_P,~] = CS4300_WP_estimates(breezes,stench,num_trials);
    if screamed
        Wumpus_P = zeros(4,4);
    end

    danger_P = pits_P + Wumpus_P;
end

frontiers = CS4300_frontier(visited);

% On the Gold
if isempty(plan)
    if percept(3)
        [so,~] = CS4300_Wumpus_A_star(board,[agent.x,agent.y,agent.dir],...
            [1,1,0],'CS4300_A_star_Man');
        plan = [GRAB;so(2:end,end);CLIMB];
    end
end

% Plan a route to the closest safe square that it has not visited yet
if isempty(plan)
    safe_close = CS4300_choose_closest(danger_P, frontiers, [agent.x,agent.y],1);
    if ~isempty(safe_close)
        board(4 - safe_close(2) + 1, safe_close(1)) = 0;
        [so,~] = CS4300_Wumpus_A_star(board,[agent.x,agent.y,agent.dir],...
            [safe_close(1),safe_close(2),0],'CS4300_A_star_Man');
        plan = so(2:end,end);
    end
end

% See if still have arrow
if isempty(plan)
    if have_arrow
        % Find the position of Wumpus
        W_pos = [-1,-1];
        for col = 1:4
            for row = 1:4
                if Wumpus_P(col,row) >= 0.5
                    W_pos = [row,4-col+1];
                end
            end
        end
        
        if W_pos(1) ~= -1            
            % Add all possible safe position that can make a shoot
            valid_pos = [];

            for celly = 1:length(visited(:,1))
                if celly ~= W_pos(1,:) & visited(celly,W_pos(1))
                    valid_pos = [valid_pos; W_pos(1), celly];
                end
            end

            for cellx = 1:length(visited(1,:))
                if cellx ~= W_pos(:,1) & visited(4-W_pos(2)+1,cellx)
                    valid_pos = [valid_pos; cellx, W_pos(2)];
                end
            end

            closest = [];
            if ~isempty(valid_pos)
                % find the closest square
                closest_dis = 99;
                for i = 1:length(valid_pos(:,1))
                    temp = [valid_pos(i,1),valid_pos(i,2)];
                    if CS4300_A_star_Man([agent.x,agent.y], temp) < closest_dis
                        closest = temp;
                        closest_dis = CS4300_A_star_Man([agent.x,agent.y],...
                            closest);
                    end
                end
            end

            %SHOOT
            if ~isempty(closest)
                [so,~] = CS4300_Wumpus_A_star(board,[agent.x,agent.y,...
                    agent.dir],[closest(1),closest(2),0],'CS4300_A_star_Man');
                if ~isempty(so)
                    % Flag to show need turn sequence
                    future_agent.x = so(end,1);
                    future_agent.y = so(end,2);
                    future_agent.dir = so(end,3);
                    plan = [so(2:end,end); CS4300_gen_turn_seq(closest, W_pos,...
                        future_agent); SHOOT];
                else
                    plan = [CS4300_gen_turn_seq(closest, W_pos,agent);SHOOT];
                end
            end
            
        end
    end
end

% Looks for a square to explore that is not provably unsafe
% Take a risk
if isempty(plan)
    OK_close = CS4300_choose_closest(danger_P,frontiers, [agent.x,agent.y],0);
    if ~isempty(OK_close)
        board(4 - OK_close(2) + 1, OK_close(1)) = 0;
        [so,~] = CS4300_Wumpus_A_star(board,[agent.x,agent.y,agent.dir],...
            [OK_close(1),OK_close(2),0],'CS4300_A_star_Man');
        plan = so(2:end,end);
    end
end

% DIE TRYING

% The mission is impossible, retreats to [1,1]
% if isempty(plan)
%     [so,no] = CS4300_Wumpus_A_star(board,[agent.x,agent.y,agent.dir],...
%         [1,1,0],'CS4300_A_star_Man');
%     plan = [so(2:end,end), CLIMB];
% end

% Execute the action from the plan one by one
action = plan(1);
plan = plan(2:end);

on_new = 0;

if action==FORWARD
    [x_new,y_new] = CS4300_move(agent.x,agent.y,agent.dir);
    agent.x = x_new;
    agent.y = y_new;
    on_new = ~visited(4-y_new+1,x_new);
    visited(4-y_new+1,x_new) = 1;
end

if action==RIGHT
    agent.dir = rem(agent.dir+3,4);
end

if action==LEFT
    agent.dir = rem(agent.dir+1,4);
end

if action==SHOOT
    have_arrow = 0;
end