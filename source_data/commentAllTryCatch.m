function commentAllTryCatch(comment)
% SYNTAX:
%    commentAllTryCatch(comment)
% EXAMPLE:
%    commentAllTryCatch(true)
%
% DESCRIPTION:
%    comment or uncomment all  try    cathc for debugging purpouse
%
% INPUT:
%   comment : if true comment if false decomment
%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

if nargin < 1
    comment = true;
end

% find all the m files in App directory

base_dir = '.';
filter = '*.m';
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
if comment
    tic
    for i = 1 : length(list)
        file_name = list{i};
        if isempty(strfind(file_name,'thirdParty')) & isempty(strfind(file_name,'commentAllTryCatch'))
        fid = fopen(file_name, 'r');
        txt = fread(fid,'*char')';
        fclose(fid);
        %occurencies = regexp(txt, expression, 'once');
        %clean_txt = regexprep(txt, expression, replace);
        occurencies = regexp(txt,' try');

        clean_txt = regexprep(txt, ' try', '%AUTCOMMS try');
        clean_txt = regexprep(clean_txt, '\ttry', '%AUTCOMMT try');


        occurencies = strfind(clean_txt, 'catch');
        clean_txt = strrep(clean_txt, 'catch', 'if false %AUTCOMM');

        if not(isempty(clean_txt)) && ~isempty(occurencies)
            fprintf('Opening file %3d/%3d: %s', i, length(list), file_name);
            fid = fopen(file_name, 'w');
            fwrite(fid, clean_txt);
            fclose(fid);
            fprintf(' -> changed\n');
        end
        end
    end
    toc;
else
    tic
    for i = 1 : length(list)
        file_name = list{i};
                if isempty(strfind(file_name,'thirdParty')) & isempty(strfind(file_name,'commentAllTryCatch'))

        fid = fopen(file_name, 'r');
        txt = fread(fid,'*char')';
        fclose(fid);
        %occurencies = regexp(txt, expression, 'once');
        %clean_txt = regexprep(txt, expression, replace);
        occurencies = strfind(txt, '%AUTCOMMS try');
        clean_txt = strrep(txt,'%AUTCOMMS try', ' try');
        clean_txt = strrep(clean_txt,'%AUTCOMMT try', '\ttry');


        occurencies = strfind(clean_txt,  'if false %AUTCOMM');
        clean_txt = strrep(clean_txt, 'if false %AUTCOMM', 'catch');


        if not(isempty(clean_txt)) && ~isempty(occurencies)
            fprintf('Opening file %3d/%3d: %s', i, length(list), file_name);
            fid = fopen(file_name, 'w');
            fwrite(fid, clean_txt);
            fclose(fid);
            fprintf(' -> changed\n');
        end
                end
    end
    toc;
end