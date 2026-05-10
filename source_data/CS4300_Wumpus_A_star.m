function [solution,nodes] = CS4300_Wumpus_A_star(board,initial_state,goal_state,h_name)
% CS4300_Wumpus_A_star - A* algorithm for Wumpus world
% On input:
%       board (4x4 int array): Wumpus board layout
%           0: means empty cell
%           1: means a pit in cell
%           2: means gold (only) in cell
%           3: means Wumpus (only) in cell
%           4: means gold and Wumpus in cell
%       initial_state (1x3 vector): x,y,dir state
%       goal_state (1x3 vector): x,y,dir state
%       h_name (string): name of heuristic function
% On output:
%       solution (nx4 array): solution sequence of state and the action
%       nodes (search tree data structure): search tree
%           (i).parent (int): index of node’s parent
%           (i).level (int): level of node in search tree
%           (i).state (1x3 vector): [x,y,dir] state represented by node
%           (i).action (int): action along edge from parent to node
%           (i).g (int): path length from root to node
%           (i).h (float): heuristic value (estimate from node to goal)
%           (i).cost (float): g + h (called f value in text)
%           (i).children (1xk vector): list of node’s children
% Call:
%       [so,no] = CS4300_Wumpus_A_star1([0,0,0,0;0,0,0,1;0,2,1,3;0,0,0,0],...
%       [1,1,0],[2,2,1],’CS4300_A_star_Man’)
%       so =
%       1 1 0 0
%       2 1 0 1
%       2 1 1 3
%       2 2 1 1
%
%       no = 1x9 struct array with fields:
%           parent
%           level
%           state
%           action
%           cost
%           g
%           h
%           children
% Author:
% Tim Wei, Haochen Zhang
% UU
% Fall 2017
%

nodes(1).parent = [];
nodes(1).level = 0;
nodes(1).state = initial_state;
nodes(1).action = 0;
nodes(1).g = 0;
nodes(1).h = feval(h_name, initial_state, goal_state);
nodes(1).cost = 0;
nodes(1).children = [];
num_nodes = 1;
frontier = [1];
explored = [];
while 1==1
    if isempty(frontier)
        solution = [];
        return
    end
    node = frontier(1);
    frontier = frontier(2:end);
    explored = [explored,node];
    if CS4300_Wumpus_solution(board,nodes(node).state,goal_state)
        solution = CS4300_traceback(nodes,node);
        return
    end
    for action = 1:3
        next_state = CS4300_Wumpus_transition(nodes(node).state,...
            action,board);
        if next_state(1)>0 ...
            & CS4300_Wumpus_new_state(next_state,frontier,explored,...
                nodes)
            num_nodes = num_nodes + 1;
            nodes(num_nodes).parent = node;
            nodes(num_nodes).level = nodes(node).level + 1;
            nodes(num_nodes).state = next_state;
            nodes(num_nodes).action = action;
            nodes(num_nodes).g = nodes(num_nodes).level;
            nodes(num_nodes).h = feval(h_name, next_state, goal_state);
            nodes(num_nodes).cost = nodes(num_nodes).g + nodes(num_nodes).h;
            nodes(num_nodes).children = [];
            nodes(node).children = [nodes(node).children,num_nodes];
            for i = 1:length(frontier)
                if nodes(frontier(i)).cost > nodes(num_nodes).cost
                    frontier = [frontier(1:i-1),num_nodes,frontier(i:end)];
                    break;
                end
                if i == length(frontier)
                    frontier = [frontier,num_nodes];
                    break;
                end
            end
            if isempty(frontier)
                frontier = [num_nodes];
            end
        end
    end
end
