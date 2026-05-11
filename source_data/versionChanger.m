function versionChanger(new_version_str, base_dir)
% SYNTAX:
%    versionChanger(new_version_str, base_dir);
% EXAMPLE:
%    versionChanger('0.5.0');
%
% DESCRIPTION:
%    Change the version number in all the App source files with standard
% header - it requires a unix system
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

% find all the m files in App directory
if (nargin <= 1)
    base_dir = '.';
end

% Cleaning spaces
fprintf('Cleaning spaces\n');
sourceCleaner(base_dir);

fprintf('\nChanging version\n');
if (nargin == 0)
    new_version_str = Core.APP_VERSION;
end
[~, list] = dos(['find ' base_dir ' -name \*.m']);
list = textscan(list,'%s','Delimiter','\n','whitespace','');
list = list{1};

tic
for i = 1 : length(list)
    file_name = list{i};
    fprintf('Opening file %3d/%3d: %s', i, length(list), file_name);
    fid = fopen(file_name, 'r');
    txt = char(fread(fid))';
    fclose(fid);
    te = regexp(txt, '(?<=(\n%\s*\|___\/\s*v\s*))(.[^\n]*)','once','tokenExtents');
    if not(isempty(te))
        txt = [txt(1:te(1)) new_version_str txt(te(2)+1:end)];
        fid = fopen(file_name, 'w');
        fwrite(fid, txt);
        fclose(fid);
        fprintf(' -> changed\n');
    else
        fprintf('\n');
    end
end
toc;