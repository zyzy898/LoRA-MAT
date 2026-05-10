function action = CS4300_hybrid_agent(percept)
% CS4300_hybrid_agent - hybrid random and logic-based agent
% On input:
% percept( 1x5 Boolean vector): percepts
%               stench, breeze, glitter, scream, bump
% On output:
% action (int): action selected by agent
% Call:
% a = CS4300_hybrid_agent([0,0,0,0,0]);
% Author:
% Haochen Zhang & Tim Wei
% UU
% Fall 2017
%

persistent plan board agent safe visited have_arrow W_pos KB on_new

if isempty(board)
    plan = [];
    board = ones(4,4);
    board(4,1) = 0;
    agent.x = 1;
    agent.y = 1;
    agent.dir = 0;
    visited = zeros(4,4);
    visited(4,1) = 1;
    safe = -ones(4,4);
    safe(4,1) = 1;
    have_arrow = 1;
    % Wampus position unknown
    W_pos = [-1,-1];
    [~,KB,~] = BR_gen_KB();
    on_new = 1;
end

FORWARD = 1;
RIGHT = 2;
LEFT = 3;
GRAB = 4;
SHOOT = 5;
CLIMB = 6;

P_offset = 0;
G_offset = 16;
B_offset = 32;
S_offset = 48;
W_offset = 64;

% Update KB
sentence = CS4300_make_percept_sentence(percept,agent.x,agent.y);
KB = CS4300_Tell(KB, sentence);

% Update safe
if on_new
    for celly = 1:length(safe(:,1))
        for cellx = 1:length(safe(1,:))
            if safe(4-celly+1,cellx) == -1
                index = cellx + 4 * (celly - 1);
                P_index = index + P_offset;
                W_index = index + W_offset;
                check_no_pit =  CS4300_Ask(KB, CS4300_literal_CNF(-P_index));
                check_no_W = CS4300_Ask(KB, CS4300_literal_CNF(-W_index));
%                 if celly ==2 & cellx ==2 &agent.x==2&agent.y==2
%                     disp('ya')
%                     t = tic;
%                 end
                if check_no_pit && check_no_W
                    safe(4-celly+1,cellx) = 1;
                    board(4-celly+1,cellx) = 0;
                    continue;
                end
%                 if celly ==2 & cellx ==2 &agent.x==2&agent.y==2
%                     toc(t)
%                 end
                
                check_pit =  CS4300_Ask(KB, CS4300_literal_CNF(P_index));
                if check_pit
                    safe(4-celly+1,cellx) = 0;
                    continue;
                end

                % Locate the Wampus if not located
                if W_pos(:,1) == -1
                    check_W = CS4300_Ask(KB, CS4300_literal_CNF(W_index));
                    if check_W
                        safe(4-celly+1,cellx) = 0;
                        W_pos = [4-celly+1,cellx];
                        continue;
                    end
                end
            end
        end
    end
end

% Ask KB if the current has glitter.
if isempty(plan)
    G_index = agent.x + 4 * (agent.y - 1) + G_offset;
    if CS4300_Ask(KB, CS4300_literal_CNF(G_index))
        [so,no] = CS4300_Wumpus_A_star(board,[agent.x,agent.y,agent.dir],...
            [1,1,0],'CS4300_A_star_Man');
        plan = [GRAB;so(2:end,end);CLIMB];
    end
end

% Plan a route to the closest safe square that it has not visited yet
if isempty(plan)
    safe_close = CS4300_choose_closest(safe,visited, [agent.x,agent.y],1);
    if ~isempty(safe_close)
        [so,no] = CS4300_Wumpus_A_star(board,[agent.x,agent.y,agent.dir],...
            [safe_close(1),safe_close(2),0],'CS4300_A_star_Man');
        plan = [so(2:end,end)];
    end
end

% See if still have arrow
if isempty(plan)
    if have_arrow && W_pos(1) ~= -1
        % Add all possible safe position that can make a shoot
        valid_pos = [];
        
        for celly = 1:length(safe(:,1))
            if celly ~= W_pos(1,:) && safe(celly,W_pos(1)) == 1
                valid_pos = [valid_pos; celly,W_pos(1)];
            end
        end
        
        for cellx = 1:length(safe(1,:))
            if cellx ~= W_pos(:,1) && safe(W_pos(2), cellx) == 1
                valid_pos = [valid_pos; W_pos(2), cellx];
            end
        end
                
        closest = [];
        if ~isempty(valid_pos)
            % find the closest square
            closest_dis = 99;
            for i = 1:length(valid_pos(:,1))
                temp = [valid_pos(i,2),4-valid_pos(i,1)+1];
                if CS4300_A_star_Man([agent.x,agent.y], temp) < closest_dis
                    closest = temp;
                    closest_dis = CS4300_A_star_Man([agent.x,agent.y],...
                        closest);
                end
            end
        end
        
        %SHOOT
        if ~isempty(closest)
            [so,no] = CS4300_Wumpus_A_star(board,[agent.x,agent.y,...
                agent.dir],[closest(1),closest(2),0],'CS4300_A_star_Man');
            % Flag to show need turn sequence
            plan = [so(2:end,end), CS4300_gen_turn_seq(closest, W_pos,...
                agent), SHOOT];
        end
    end
end

% Looks for a square to explore that is not provably unsafe
% Take a risk
if isempty(plan)
    OK_close = CS4300_choose_closest(safe,visited, [agent.x,agent.y],0);
    if ~isempty(OK_close)
        board(4 - OK_close(2) + 1, OK_close(1)) = 0;
        [so,no] = CS4300_Wumpus_A_star(board,[agent.x,agent.y,agent.dir],...
            [OK_close(1),OK_close(2),0],'CS4300_A_star_Man');
        plan = [so(2:end,end)];
    end
end

% The mission is impossible, retreats to [1,1]
if isempty(plan)
    [so,no] = CS4300_Wumpus_A_star(board,[agent.x,agent.y,agent.dir],...
        [1,1,0],'CS4300_A_star_Man');
    plan = [so(2:end,end), CLIMB];
end

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