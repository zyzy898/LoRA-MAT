function data = zero2n(data,n)
% SYNTAX:
%   data = zero2n(data,n)
% DESCRIPTION:
%   return the array with zeros substituted by n

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Giulio Tagliaferro
%  Contributors:     Giulio Tagliaferro, ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    
    if ~(isa(data, 'double') || isa(data, 'single'))
        data = double(data);
    end
    data(data == 0) = n;
end