function action = CS4300_agent_Astar(percept)
% CS4300_agent_Astar - A* search agent example
% Uses A* to find best path back to start
% On input:
% percept (1x5 Boolean vector): percept values
% (1): Stench
% (2): Breeze
% (3): Glitters
% (4): Bumped
% (5): Screamed
% On output:
% action (int): action selected by agent
% FORWARD = 1;
% ROTATE_RIGHT = 2;
% ROTATE_LEFT = 3;
% GRAB = 4;
% SHOOT = 5;
% CLIMB = 6;
% Call:
% a = CS4300_agent_Astar([0,0,0,0,0]);
% Author:
% Tim Wei, Haochen Zhang
% UU
% Fall 2017
%


persistent got_gold
persistent solution
persistent step
persistent state
persistent board
persistent empty_board
%persistent visited

% Initialize static variables
if isempty(got_gold)
    got_gold = 0;
    state = [1,1,0];
    board = [1,1,1,1; 1,1,1,1; 1,1,1,1; 0,1,1,1];
    empty_board = zeros(4,4);
    %visited = [1,1];
end

% Standing on the gold
if percept(3) && isempty(solution)
    %{
    % Mark all the spots in the board as pit
    board = [1,1,1,1; 1,1,1,1; 1,1,1,1; 1,1,1,1];
    
    % Mark visited spots in the board as clear
    [leng,~] = size(visited);
    for i = 1:leng
        board(5-visited(i,2),visited(i,1)) = 0;
    end
    %}
    got_gold = 1;
    % TODO call A* find way back
    [solution,nodes] = CS4300_Wumpus_A_star(board, state, [1,1,0], 'CS4300_m_distance');
    %disp(length(nodes));
    %[~,nodes] = CS4300_Wumpus_BFS(board, state, [1,1,0]);
    %disp(length(nodes));
    %[~,nodes] = CS4300_Wumpus_DFS(board, state, [1,1,0]);
    %disp(length(nodes));
    
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
    % randomly and equally choose from three available actions
    action = randi(3);
    state = CS4300_Wumpus_transition(state,action,empty_board);
    
    x = state(1);
    y = state(2);
    if x ~= -1
        board(5-y,x) = 0;
    end
    %{
    % If the next state output by transition is an unvisited cell, record
    % it in visited.
    % Otherwise, ignore it.
    v = 0;
    [leng,~] = size(visited);
    for i = 1:leng
        if visited(i,1) == state(1) && visited(i,2) == state(2)
            v = 1;
            break;
        end
    end
    if ~v
        visited = [state(1),state(2); visited];
    end
    %}
end