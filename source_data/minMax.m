function [min_max] = minMax(data)
% SYNTAX:
%   [min_max] = minMax(data);
%
% INPUT:
%   data      the input dataset
%
% OUTPUT:
%   min_max = [2 x 1] minimum and maximum of a dataset
%
% DESCRIPTION:
%   get the minimum and maximum value of a dataset
%   since is not builtin it is probably better to use min_max = [min(data(:)) max(data(:))]

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    min_max = [min(data(:)) max(data(:))];
end