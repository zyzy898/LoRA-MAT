function str_out = structToString(data, show, level, str)
% Display the content of a structure

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    if (nargin  < 2)
        show = true;
    end
    if (nargin  < 3)
        level = 0;
    end
    if (nargin  < 4)
        str = '';
    end

    key = fieldnames(data);
    for k = 1 : numel(key)
        if isstruct(data.(key{k}))
            str = sprintf('%s%*c -> %s\n', str, 4 * level, char(32), key{k});
            str = structToString(data.(key{k}), level+1, false, str);
        else
            tmp = toIniString(key{k}, data.(key{k}));
            str = sprintf('%s%*c -> %s\n', str, 4 * level, char(32), tmp{1});

        end
    end

    if show
        fprintf(str);
    end

    if (nargout == 1)
        str_out = str;
    end

end

% toIniString -----------------------------------------------------
function cell_str = toIniString(variable_name, value, format, cell_str)
% Convert any variable to ini string format
% SYNTAX:
%   cell_str = toIniString(variable_name, value)
%   cell_str = toIniString(variable_name, value, format)
%   cell_str = toIniString(variable_name, value, cell_str)
%   cell_str = toIniString(variable_name, value, format, cell_str)
switch nargin
    case 1
        error('Error in Ini_Manager.toIniString, too few parameters');
    case 2

        format = '';
        cell_str = {};
    case 3
        if iscellstr(format)
            cell_str = format;
            format = '%g';
        else
            cell_str = {};
        end
    case 4
        % ok
end
if ~isdeployed
    variable_name = ['<strong>' variable_name '</strong>'];
end
if ischar(value) % is string
    cell_str{numel(cell_str) + 1} = [variable_name ' = "' value(:)' '"'];
elseif isnumeric(value)
    if isempty(format)
        format = '%g';
    else
        format = strtrim(format);
    end
    if numel(value) > 1 % it's an array of values
        format = [format ' '];
        tmp = sprintf(format,value);
        cell_str{numel(cell_str) + 1} = [variable_name ' = [' tmp(1:end-1) ']'];
        clear tmp;
    else
        cell_str{numel(cell_str) + 1} = [variable_name ' = ' sprintf(format,value)];
    end
else % generic converter (may not work properly)
    toString = @(var) strtrim(regexprep(evalc('disp(var)'), '\n', ''));
    if iscell(value)
        if ~isempty(value) && ischar(value{1})
            cell_str{numel(cell_str) + 1} = [variable_name ' = [' Ini_Manager.strCell2Str(value) ']'];
        else
            cell_str{numel(cell_str) + 1} = [variable_name ' = [' toString(value) ']'];
        end
    else
        cell_str{numel(cell_str) + 1} = [variable_name ' = ' toString(value)];
    end
end

% I want a column array
if size(cell_str,1) < size(cell_str,2)
    cell_str = cell_str';
end
end