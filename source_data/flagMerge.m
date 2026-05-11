% SYNTAX:
%    flag = flagMerge(flag, expand_size)
%
% DESCRIPTION:
%    merge the flag array
%    if flag is a matrix this flagging expansion will work column by column
%
% INPUT:
%   flag          [n_obs x n_arrays]
%   expand_size   n_epochs with flags to activate at the border of a flagged interval

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

function flag = flagMerge(flag, expand_size)
    % compute a moving window median to filter the data in input
    
    for c = 1 : size(flag, 2)
        flag(:, c) = ~(conv(single(~(conv(single(flag(:, c)), ones(2 * expand_size + 1, 1), 'same') > 0)), ones(2 * expand_size + 1, 1), 'same') > 0);
    end
end