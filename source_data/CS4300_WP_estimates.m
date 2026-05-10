function [pits,Wumpus,fail] = CS4300_WP_estimates(breezes,stench,num_trials)
% CS4300_WP_estimates - estimate pit and Wumpus likelihoods
% On input:
%       breezes (4x4 Boolean array): presence of breeze percept at cell
%           -1: no knowledge
%           0: no breeze detected
%           1: breeze detected
%       stench (4x4 Boolean array): presence of stench in cell
%           -1: no knowledge
%           0: no stench detected
%           1: stench detected
%       num_trials (int): number of trials to run (subset will be OK)
% On output:
%       pits (4x4 [0,1] array): likelihood of pit in cell
%       Wumpus (4x4 [0 to 1] array): likelihood of Wumpus in cell
%       fail (boolean): the function failed to run num_trials times
% Call:
%       breezes = -ones(4,4);
%       breezes(4,1) = 1;
%       stench = -ones(4,4);
%       stench(4,1) = 0;
%       [pts,Wumpus] = CS4300_WP_estimates(breezes,stench,10000)
%       pts =
%       0.2021 0.1967 0.1956 0.1953
%       0.1972 0.1999 0.2016 0.1980
%       0.5527 0.1969 0.1989 0.2119
%       0 0.5552 0.1948 0.1839
%
%       Wumpus =
%       0.0806 0.0800 0.0827 0.0720
%       0.0780 0.0738 0.0723 0.0717
%       0 0.0845 0.0685 0.0803
%       0 0 0.0741 0.0812
% Author:
%       Haochen Zhang & Tim Wei
%       UU
%       Fall 2016
%

fail = 0;
pits = zeros(4,4);
Wumpus = pits;
if ~num_trials
    return;
end
count = 0;
board_count = 0;
for t = 1:num_trials
    b = CS4300_gen_board(0.2);
    board_count = board_count + 1;
    while ~CS4300_board_fits_percept(breezes,stench,b)
        if board_count > 10000 && count > 0 || board_count > 1000000
            fail = 1;
            pits = pits / count;
            Wumpus = Wumpus / count;
            return;
        end
        b = CS4300_gen_board(0.2);
        board_count = board_count + 1;
    end
    count = count + 1;
    pits = pits + (b == 1);
    Wumpus = Wumpus + (b > 2);
end
pits = pits / count;
Wumpus = Wumpus / count;