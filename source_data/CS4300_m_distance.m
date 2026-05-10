function d = CS4300_m_distance(initial_state, goal_state)
% CS4300_Wumpus_transition - transition function for Wumpus action
% On input:
%     initial_state (1x3 vector): [x,y,dir] state of agent
%     goal_state(1x3 vector): [x,y,dir] state of agent
% Call:
%     d = CS4300_m_distance([1,1,0],[2,2,0])
% Author:
%     Haochen Zhang & Tim Wei
%     UU
%     Fall 2015
%

d = abs(initial_state(1) - goal_state(1)) + abs(initial_state(2) - goal_state(2));