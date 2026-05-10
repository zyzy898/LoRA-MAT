function [errorcode, varargout] = common_size (varargin)

% COMMON_SIZE  Checks that all inputs are either scalar or of common size
%  [ERR, Y1, ...] = common_size(X1, ...)
%  Determine if all input arguments are either scalar or of common
%  size.  If so, ERR is zero, and YI is a matrix of the
%  common size with all entries equal to XI if this is a scalar or
%  XI otherwise.  If the inputs cannot be brought to a common size,
%  errorcode is 1, and YI is XI.
%
%  Example:
%   [errorcode, a, b] = common_size([1 2; 3 4], 5)
%      >> errorcode = 0
%      >> a = [ 1, 2; 3, 4 ]
%      >> b = [ 5, 5; 5, 5 ]

%  Software version 1.0.1
%-------------------------------------------------------------------------------
% Copyright (C) 1995-2007 Kurt Hornik
% Copyright (C) 2008 Dynare Team
% Copyright (C) 2024 Geomatics Research & Development srl (GReD)
% Adapted from Octave
%  Written by:       KH <Kurt.Hornik@wu-wien.ac.at>
%  Contributors:     Andrea Gatti ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

if (nargin < 2)
    error ('common_size: only makes sense if nargin >= 2');
end

len = 2;
for i = 1 : nargin
    sz =  size (varargin{i});
    if (length (sz) < len)
        s(i,:) = [sz, ones(1,len - length(sz))];
    else
        if (length (sz) > len)
            if (i > 1)
                s = [s, ones(size(s,1), length(sz) - len)];
            end
            len = length (sz);
        end
        s(i,:) = sz;
    end
end

m = max (s);
if (any (any ((s ~= 1)') & any ((s ~= ones (nargin, 1) * m)')))
    errorcode = 1;
    varargout = varargin;
else
    errorcode = 0;
    for i = 1 : nargin
        varargout{i} = varargin{i};
        if (prod (s(i,:)) == 1)
            varargout{i} = varargout{i} * ones (m);
        end
    end
end