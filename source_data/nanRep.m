function data = nanRep(data, flags)
% SYNTAX:
%   data = nanRep(data, flags)
% DESCRIPTION:
%   return the array with NaNs on the positions specified in flags

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    data(flags) = nan;
end