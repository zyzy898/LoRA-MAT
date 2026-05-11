% SYNTAX:
%    flag = flagShrink(flag, expand_size, <omit_borders = false>)
%
% DESCRIPTION:
%    shrink the flag array
%    if flag is a matrix this flagging expansion will work column by column
%
% INPUT:
%   flag          [n_obs x n_arrays]
%   expand_size   n_epochs with flags to activate at the border of a flagged interval
%   omit_borders  when true do not shrink flags at the beginning or end of the matrix

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

function flag = flagShrink(flag, expand_size, omit_borders)    
    if nargin < 3
        omit_borders = false;
    end
    for c = 1 : size(flag, 2)
        flag(:, c) = ~conv(single(~flag(:, c)), ones(2 * expand_size + 1, 1)', 'same') > 0;
    end
    if omit_borders
        % do nothing
    else
        flag([1:expand_size (end - expand_size + 1) : end], :) = 0;
    end
end