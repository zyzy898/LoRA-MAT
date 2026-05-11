function [universal_path, is_valid] = checkPath(path)

% SYNTAX:
%   universal_path = checkPath(path)
%
% INPUT:
%   path
%
% OUTPUT:
%   universal_path
%   < is_valid >            optional, contains the status of existence
%
% DESCRIPTION:
%   Conversion of path OS specific to a universal one: "/" or "\" are converted to filesep
%   if the second output parameter is present is_valid contains the status of existence
%       2 => is a file
%       7 => is a folder

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

if nargout == 2
    [universal_path, is_valid] = File_Name_Processor.checkPath(path);
else
    universal_path = File_Name_Processor.checkPath(path);
end