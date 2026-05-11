function sourceCleaner(base_dir, rem_spaces)
% SYNTAX:
%    sourceCleaner( base_dir);
% EXAMPLE:
%    versionChanger();
%
% DESCRIPTION:
%    Remove all the spaces at the end of the lines
% header - it requires a unix system
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

% find all the m files in App directory
if (nargin < 1)
    base_dir = '.';
end
if (nargin < 2)
    rem_spaces = false;
end

if ~exist(base_dir, 'dir')
    if iscell(base_dir)
        list = base_dir;
    else
        list = {base_dir};
    end
else
    [~, list] = dos(['find ' base_dir ' -name \*.m']);
    list = textscan(list,'%s','Delimiter','\n','whitespace','');
    list = list{1};
end
tic
for i = 1 : length(list)
    file_name = list{i};
    fprintf('Opening file %3d/%3d: %s', i, length(list), file_name);
    fid = fopen(file_name, 'r');
    txt = fread(fid,'*char')';
    fclose(fid);
    clean_txt = regexprep(txt,'(?<=[A-Za-z]|\%|;|\)|[0-9])([ |\t|\r]*(?=\n))','');
    if rem_spaces
        clean_txt = regexprep(clean_txt,'(?<=\n)([ |\t|\r]*(?=[A-Za-z]|\%))','');
    end

    if not(isempty(clean_txt))
        fid = fopen(file_name, 'w');
        fwrite(fid, clean_txt);
        fclose(fid);
        fprintf(' -> changed\n');
    else
        fprintf('\n');
    end
end
toc;