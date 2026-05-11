function [flag_intervals] = getFlagsLimits(flags, split_point)
% INPUT
%   flags           flag array (as logical)
%   split_point     points with forced splits (as logical)
%
% SYNTAX
%   [flag_intervals] = getFlagsLimits(flags, <split_point>)
%
% DESCRIPTION
%   Returns start and end of flagged intervals
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    % convert flags into array
    if isstruct(flags)
        diff_tmp = -diff(int8([0; logical(struct2flagVec(flags, max(flags.pos + 1))); 0]));
        % add padding to avoid problem with flags on the borders
    else
        diff_tmp = -diff(int8([0; logical(full(flags(:))); 0]));
    end
    
    if nargin == 2 && ~isempty(split_point)
        split_point = split_point & flags;
        d_tmp = diff_tmp; 
        d_tmp(1 : end-1) = (d_tmp(1 : end-1) - 2 * int8(full(split_point)));
        f_i1 = find(d_tmp < 0);
        f_i2 = find([split_point; false] | d_tmp > 0);
        for i = 1 : numel(f_i1)
            if f_i1(i) == f_i2(i)
                f_i2(i) = [];
            end
        end
        flag_intervals = [f_i1, f_i2 - 1];
    else
        flag_intervals = [find(diff_tmp < 0), find(diff_tmp > 0) - 1];
    end
end

function [flag_array] = struct2flagVec(flags, maxSize)
    flag_array = false(maxSize,1);
    flag_array(flags.pos) = flags.val;
end