function data = nan2zero(data)
% SYNTAX:
%   data = nan2zero(data)
% DESCRIPTION:
%   return the array with NaNs substituted by zeros

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    data(isnan(data)) = 0;
end