function action = CS4300_agent_Astar_PC(percept)
% CS4300_agent_Astar_PC - A* search agent with PC
% Uses A* to find best path back to start and PC to avoid trouble
% On input:
%     percept (1x5 Boolean vector): percept values
%     (1): Stench
%     (2): Breeze
%     (3): Glitters
%     (4): Bumped
%     (5): Screamed
% On output:
%     action (int): action selected by agent
%         FORWARD = 1;
%         ROTATE_RIGHT = 2;
%         ROTATE_LEFT = 3;
%         GRAB = 4;
%         SHOOT = 5;
%         CLIMB = 6;
% Call:
%     a = CS4300_agent_Astar_PC([0,0,0,0,0]);
% Author:
%     Tim Wei, Haochen Zhang
%     UU
%     Fall 2017
%

persistent got_gold solution state board empty_board G D on_new

% Initialize static variables
if isempty(got_gold)
    got_gold = 0;
    state = [1,1,0];
    board = [1,1,1,1; 1,1,1,1; 1,1,1,1; 0,1,1,1];
    empty_board = zeros(4,4);
    G = zeros(16,16);
    for x = 1:4
        for y = 1:4
            node = x + (y-1) * 4;
            if x ~= 1
                G(node,node-1) = 1;
            end
            if x ~= 4
                G(node,node+1) = 1;
            end
            if y ~= 1
                G(node,node-4) = 1;
            end
            if y ~= 4
                G(node,node+4) = 1;
            end
        end
    end
    D = ones(16,3);
    D(1,2) = 0;
    on_new = 1;
end

% Standing on the gold
if percept(3) && isempty(solution)
    got_gold = 1;
    % TODO call A* find way back
    [solution,~] = CS4300_Wumpus_A_star(board, state, [1,1,0],...
        'CS4300_m_distance');
    
    % First step is empty
    solution(1,:) = [];
    
    % Pick the gold
    action = 4;
    return;
end

if got_gold
    if ~isempty(solution)
        % Receive and process the action
        action = solution(1, 4);
    	solution(1,:) = [];
    else
        % Climb out
        action = 6;
    end
else
    x = state(1);
    y = state(2);
    if on_new 
        on_new = 0;
        node = x + (y-1) * 4;
        D(node,2) = 0;
        if ~percept(2)
            D(node,3) = 0;
        end
        D = CS4300_PC(G,D,'CS4300_P_no_attack');
        % determines if a safe cell exists that has not been visited
        for node = 1:16
            if ~D(node,2)
                x = mod(node,4);
                if ~x
                    x = 4;
                end
                y = floor((node-1) / 4 + 1);
                if board(5-y,x)
                    board(5-y,x) = 0;
                    [solution,~] = CS4300_Wumpus_A_star(board, state, [x,y,0],...
                        'CS4300_m_distance');
                    solution(1,:) = [];
                    board(5-y,x) = 1;
                    break;
                end
            end
        end
    end
    
    if ~isempty(solution)
        % Receive and process the action
        action = solution(1, 4);
        solution(1,:) = [];
    else
        % randomly and equally choose from three available actions
        action = randi(3);
    end
    
    state = CS4300_Wumpus_transition(state,action,empty_board);
    
    x = state(1);
    y = state(2);
    if x ~= -1
        if board(5-y,x)
            on_new = 1;
        end
        board(5-y,x) = 0;
    end
end
