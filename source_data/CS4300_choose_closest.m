function closest = CS4300_choose_closest(danger,frontiers,current_pos, mode)
% CS4300_choose1 - choose a closest safe place to go or choos a closest...
%                   OK place with the lowest probability of ...
%                   danger (probability of pits + probability of Wumpus)
% On input:
%     danger (4x4 array): 0 if safe, 0.xx means the possibility of ...
%                   danger (probability of pits + probability of Wumpus)
%     frontiers (4x4 array): 1 if is frontier, else 0
%     current_pos (1x2 vector): [x y] current location
%     mode (int): 1 if find SAFE cells, else find OK cells
% On output:
%     closest (1x2 vector): [x y] location
% Call:
%     closest = CS4300_choose1(danger,frontiers,current_pos, mode);
% Author:
%     Haochen Zhang & Tim Wei
%     UU
%     Fall 2015
%

% rows should be cols and cols should be rows
closest = [];
if mode == 1
    [rows,cols] = find(danger==0&frontiers==1);
else
    % Sort the danger rating
    [rows,cols] = find(danger>0&frontiers==1);
    
    num_cell = length(cols(:,1));
    sort_danger = zeros(num_cell, 3);
    for i = 1:num_cell
        sort_danger(i,1) = rows(i);
        sort_danger(i,2) = cols(i);
        sort_danger(i,3) = danger(rows(i),cols(i));
    end
    
    sort_danger = sortrows(sort_danger, 3);
    for i = 1:num_cell
        if sort_danger(i,3) ~= sort_danger(1,3)
            sort_danger = sort_danger(1:i-1,1:2);
            break
        end
    end
    rows = [];
    cols = [];
    for i = 1:length(sort_danger(:,1))
        rows(i) = sort_danger(i,1);
        cols(i) = sort_danger(i,2);
    end
end

if ~isempty(rows)
    % find the closest square
    closest_dis = 99;
    for i = 1:length(cols(:,1))
        temp = [cols(i),4-rows(i)+1];
        if CS4300_A_star_Man(current_pos, temp) < closest_dis
            closest = temp;
            closest_dis = CS4300_A_star_Man(current_pos, closest);
        end
    end
end