function str = strCell2Str(str_cell, separator)
% SYNTAX:
%   [str] = strCell2Str(str_cell, <separator == ' '>);
%
% INPUT:
%   str_cell  = cell array of strings
%   separator = <optional> contains the separator string (white space as default)
%
% OUTPUT:
%   str = single string of the element list separated by the "separator"
%
% DESCRIPTION:
%   Convert to a character array the input cell of strings

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    if nargin == 1
        separator = ' ';
    end
    if ischar(str_cell)
        str_cell = {str_cell};
    end
    if ~isempty(str_cell)
        str = str_cell{1};
        for i = 2 : numel(str_cell)
            str = sprintf('%s%s%s', str, separator, str_cell{i});
        end
    else
        str = '';
    end
end