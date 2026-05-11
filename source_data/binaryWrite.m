function binaryWrite(file_name, data)
% SYNTAX:
%    binaryWrite(file_name, data)
%
% DESCRIPTION:
%     This function write a binary matrix in binary format
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    % open the file to write

    fid = fopen( file_name, 'w' );
    fwrite(fid, size(data, 1), 'int');
    fwrite(fid, size(data, 2), 'int');

    % allocate matrix memory
    
    fwrite(fid, data(:), class(data(1)));
    fclose(fid);