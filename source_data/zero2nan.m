function data = zero2nan(data)
% SYNTAX:
%   data = zero2nan(data)
% DESCRIPTION:
%   return the array with zeros substituted by NaNs

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    
    if ~(isa(data, 'double') || isa(data, 'single'))
        data = double(data);
    end
    data(data == 0) = nan;
end