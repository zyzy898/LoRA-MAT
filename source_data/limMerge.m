% SYNTAX:
%    lim = limMerge(lim, max_gap)
%
% DESCRIPTION:
%    merge limits closer than max_gap
%
% INPUT:
%   lim           limits as arrived from getFlagsLimits
%   max_gap       n_epochs between intervals to merge

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

function lim = limMerge(lim, max_gap)
    % compute a moving window median to filter the data in input
    for l = size(lim, 1) - 1 : -1 : 1
        if (lim(l + 1, 1) - lim(l, 2)) < max_gap
            lim(l, 2) = lim(l + 1, 2);
            lim(l + 1, :) = [];
        end
    end
end