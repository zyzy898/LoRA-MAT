% implementation fo contains function, not presents in all matlab
%
% SYNTAX:
%   str_is_found = instr(str, pattern)
%


%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

function [str_is_found] = instr(str, pattern)
    str_is_found = ~isempty(strfind(str,pattern)); %#ok<STREMP>
end