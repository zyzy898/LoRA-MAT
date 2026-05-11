function [ocean_load_disp, status] = load_BLQ(filename, marker)

% SYNTAX:
%   [ocean_load_disp, status] = load_BLQ(filename, marker);
%
% INPUT:
%   filename = ocean loading displacement file (.BLQ)
%   marker   = marker name(s)
%
% OUTPUT:
%   ocean_load_disp = ocean loading displacement values read from .BLQ file
%   status = data found status flag (<0 ocean loding not found =0 marker not found >0 found)
%
% DESCRIPTION:
%   Reads ocean loading displacement values from a file in BLQ format.

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

% ocean_load_disp struct definition
% ocean_load_disp.marker : marker name
% ocean_load_disp.matrix : ocean loading displacement matrix
log = Core.getLogger();
ocean_load_disp=[];
for m = 1 : length(marker)
    ocean_load_disp(m).name = marker{m}; %#ok<*AGROW>
    ocean_load_disp(m).matrix = zeros(6,11);
    ocean_load_disp(m).available = 0;
end

status = 0;
for file_blq = 1 : size(filename,1)
    if (~isempty(filename))
        fid = fopen(char(filename(file_blq,:)),'rt');
        if (fid ~= -1)
            if (file_blq == 1)
                log.addMessage(log.indent(['Reading ocean loading file ', File_Name_Processor.getFileName(char(filename(file_blq,:))), '...']));
            end
            while (~feof(fid) && status < length(marker))
                line = fgetl(fid);
                for m = 1 : length(marker)
                    if ~isempty(strtrim(line))  && (~strcmp(line(1:2),'$$'))
                        if length(line) >= 6 && ~isempty((strfind(upper(line(1:6)), ['  ' upper(marker{m})])))
                            line = fgetl(fid);
                            while(strcmp(line(1:2),'$$'))
                                line = fgetl(fid);
                            end
                            for l = 1 : 6
                                ocean_load_disp(m).matrix(l,:) = cell2mat(textscan(line, '  %f %f %f %f %f %f %f %f %f %f %f'));
                                line = fgetl(fid);
                            end
                            ocean_load_disp(m).available = 1;
                            status = status + 1;
                            break
                        end
                    end
                end
            end
            fclose(fid);
        else
            ocean_load_disp = [];
            log.addWarning(['Ocean loading file ', char(filename(file_blq,:)), ' could not be read.']);
            status = -1;
        end
    else
        ocean_load_disp = [];
        log.addWarning('Ocean loading file not provided');
        status = -2;
    end
end

if (status == 0)
    ocean_load_disp = [];
end