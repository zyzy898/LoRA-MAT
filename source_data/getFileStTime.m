%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by: Giulio Tagliaferro
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

function time = getFileStTime(filename)
% Return the start time of the file using the standard naming convention

[~,name, ext] = fileparts(filename);
if strcmpi(ext,'.${YY}p') || ((strcmpi(ext,'.${YY}[n|N]') || ~isempty(regexpi(ext,'\.\d\d[n|N]'))) && isempty(strfind(name, 'CGIM')))  || strcmpi(ext,'.${YY}l') || ~isempty(regexpi(ext,'\.\d\d[p|P]')) || ~isempty(regexp(ext,'\.\d\d[l|L]', 'once')) %#ok<STREMP>
    % name should be : cccwwwwd
    % note: nav file rinex does not have first epoch at the beginning
    % it is too expesivo to look all the file
    if length(name) >= 8
        week = str2double(name(4:7));
        dow = str2double(name(8));
        if ~isnan(week) && ~isnan(dow)
            time = GPS_Time.fromWeekDow(week, dow);
        else
            time = [];
        end
    else
        time = [];
    end
    
elseif isempty(strfind(lower(ext),lower('eph'))) || isempty(strfind(lower(ext),lower('sp3')))
    % read first 50 lines SP3 headers is 24 (allowing some space for more line comment)
    fid = fopen(filename,'rt');
    if fid > 0
        txt = fread(fid,61*50,'*char')';
        fclose(fid);
        if isempty(txt)
            Core.getLogger.addWarning(sprintf('"%s" is empty ', filename));
            time = [];
        else
            % get new line separators
            nl = regexp(txt, '\n')';
            if isempty(nl)
                Core.getLogger.addError(sprintf('File "%s" is corrupted, deleting it', filename));
                delete(filename);
            else
                if nl(end) <  numel(txt)
                    nl = [nl; numel(txt)];
                end
                lim = [[1; nl(1 : end - 1) + 1] (nl - 1)];
                lim = [lim lim(:,2) - lim(:,1)];
                if lim(end,3) < 3
                    lim(end,:) = [];
                end
                % find time line
                idx_epoch = find(txt(lim(:,1)) == '*');
                txt = txt(lim(idx_epoch):end);
                if ~isempty(idx_epoch)
                    time = GPS_Time([str2num(txt(4:7)) str2num(txt(9:10)) str2num(txt(12:13)) str2num(txt(15:16)) str2num(txt(18:19)) str2num(txt(21:31))]);
                else
                    time = [];
                end
            end
        end
    else
        time = [];
    end
elseif isempty(strfind(lower(ext),lower('clk')))
    fid = fopen(filename,'rt');
    tline = fgetl(fid);
    i = 0;
    eoh_found = false;
    while ischar(tline) && i < 300 && eoh_found
        eoh_found = strfind(tline,'END OF HEADER');
        tline = fgetl(fid);
        i = i + 1;
    end
    fclose(fid);
    if eoh_found
        tline = fgetl(fid);
        if ischar(tline) && length(tline) >  36
            time = GPS_Time([str2num(tline(9:12)) str2num(tline(14:15)) str2num(tline(17:18)) str2num(tline(20:21)) str2num(tline(24:25)) str2num(tline(26:34))]);
        else
            time = [];
        end
    else
        time = [];
    end
    
else
    time = [];
end
end