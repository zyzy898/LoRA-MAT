function match = CS4300_board_fits_percept(breezes,stench,board)
% CS4300_board_fits_percept - return true if board matches our breezes ...
%                           and stenches, false otherwise
% On input:
%       breezes (4x4 Boolean array): presence of breeze percept at cell
%           -1: no knowledge
%           0: no breeze detected
%           1: breeze detected
%       stench (4x4 Boolean array): presence of stench in cell
%           -1: no knowledge
%           0: no stench detected
%           1: stench detected
%       board (4x4 int array): Wumpus board
%           0: nothing in room
%           1: pit in room
%           2: gold in room
%           3: Wupmus in room
%           4: both gold and Wumpus in room
% On output:
%       match (boolean): return true if board matches our breezes ...
%                           and stenches, false otherwise
% Call:
%       CS4300_board_fits_percept(breezes,stench,b);
% Author:
%       Haochen Zhang & Tim Wei
%       UU
%       Fall 2016
%

match = 0;
% loop through all cells in breezes and stench
for x = 1:4
    for y = 1:4
        cell = board(x,y);
        b = breezes(x,y);
        s = stench(x,y);
        % get neighbour of the cell
        neis = BR_Wumpus_neighbors(x,y);
        %see if the neighbous's percept fits
        for i = 1:length(neis)
            xn = neis(i,1);
            yn = neis(i,2);
            % the cell is a pit
            if cell == 1
                if ~breezes(xn,yn)
                    return;
                end
            end
            % the cell has Wampus
            if cell > 2
                if ~stench(xn,yn)
                    return;
                end
            end
            if b == 1 && board(xn,yn) == 1
                b = 0;
            end
            if s == 1 && board(xn,yn) > 2
                s = 0;
            end
        end
        if b > 0 || s > 0
            return;
        end
    end
end
match = 1;