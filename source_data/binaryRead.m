function data = binaryRead(file_name)
% SYNTAX:
%    data = binaryRead(file_name)
%
% DESCRIPTION:
%     This function read a binary matrix in binary format
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    % open the file to read

    fid = fopen(file_name, 'r');
    if fid <= 0
        fprintf('ERROR: loading %s\n', file_name);
        data = [];
    else
        r = fread(fid, 1, 'int');
        c = fread(fid, 1, 'int');
        
        % allocate matrix memory
        data = fread(fid, r * c, 'double');
        data = reshape(data, r, c);
        fclose(fid);
    end