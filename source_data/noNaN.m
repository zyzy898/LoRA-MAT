function data = noNaN(data)
% Return the array without NaN
%
% SYNTAX:
%   data = noNaN(data)
%
% SEE ALSO
%   noZero nanRep

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    data = data(~isnan(data));
end