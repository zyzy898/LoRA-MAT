function fileRep(base_dir, expression, replace, filter)
% SYNTAX:
%    fileRep( base_dir, expression, replace, <filter = '*.m'>)
% EXAMPLE:
%    fileRep('.','expression', 'replace phrase', '*.m');
%
% DESCRIPTION:
%    Replace an exprassion in all the '.m' files under base_dir - it requires a unix system
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

if nargin < 4 || isempty(filter)
    filter = '*.m';
end

% find all the m files in App directory
if isempty(base_dir)
    base_dir = '.';
end

if ~exist(base_dir, 'dir')
    if iscell(base_dir)
        list = base_dir;
    else
        list = {base_dir};
    end
else
    [~, list] = dos(['find ' base_dir ' -name \' filter]);
    if ~isempty(list)
        list = textscan(list,'%s','Delimiter','\n','whitespace','');
        list = list{1};
    end
end
tic
for i = 1 : length(list)
    file_name = list{i};
    fid = fopen(file_name, 'r');
    try
        txt = fread(fid,'*char')';
        fclose(fid);
        %occurencies = regexp(txt, expression, 'once');
        %clean_txt = regexprep(txt, expression, replace);
        occurencies = strfind(txt, expression);
        clean_txt = strrep(txt, expression, replace);

        if not(isempty(clean_txt)) && ~isempty(occurencies)
            fprintf('Opening file %3d/%3d: %s', i, length(list), file_name);
            fid = fopen(file_name, 'w');
            fwrite(fid, clean_txt);
            fclose(fid);
            fprintf(' -> changed\n');
        end
    catch ex
        Core_Utils.printEx(ex);
        fprintf('"%s" cannot be open!\n', file_name);
    end
end
toc;