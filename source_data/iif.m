function value = iif(condition, value1, value2)
% SYNTAX:
%   value = iif(condition, value1, value2)
% DESCRIPTION:
%   return value1 if condition is true otherwise value2

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    if condition
        value = value1;
    else
        value = value2;
    end
end