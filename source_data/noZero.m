function data = noZero(data)
% Return the array without zeros
%
% SYNTAX:
%   data = zeros(data)
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

    data = data(data ~= 0);
end