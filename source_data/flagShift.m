% SYNTAX:
%    flag = flagShift(flag, shift_size)
%
% DESCRIPTION:
%    shift down the flag array
%    if flag is a matrix this flagging expansion will work column by column
%
% INPUT:
%   flag          [n_obs x n_arrays]
%   shift_size    n_epochs with flags shift down (negative values are accepted)

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

function flag = flagShift(flag, shift_size)
    % compute a moving window median to filter the data in input
    if shift_size > 0
        flag = [zeros(shift_size, size(flag, 2)); flag((shift_size + 1) : end, :)];
    else
        flag = [flag(1 : (end + shift_size), :); zeros(-shift_size, size(flag, 2));];
    end
end