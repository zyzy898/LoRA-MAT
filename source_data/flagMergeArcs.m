% SYNTAX:
%    flag = flagMergeArcs(flag, max_gap)
%
% DESCRIPTION:
%    merge arcs
%
% INPUT:
%   flag          [n_obs x n_arrays]
%   min_arc       n_epochs with no flags to activate at the border of a flagged interval

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

function flag = flagMergeArcs(flag, max_gap)
    tmp_flag = [true(max_gap, size(flag, 2)); flag; true(max_gap, size(flag, 2))];
    if mod(max_gap, 2) == 0
        tmp_flag = flagShrink(flagExpand(tmp_flag, max_gap/2), max_gap/2);
    else
        tmp_flag = flagShrink(flagExpand(tmp_flag, (max_gap-1)/2), (max_gap-1)/2);
        tmp_flag(2:end-1) = tmp_flag(2:end-1) | (tmp_flag(1:end-2) & tmp_flag(3:end));
    end
    flag = tmp_flag(max_gap + (1 : size(flag, 1)) ,:);
end