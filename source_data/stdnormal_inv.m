function inv = stdnormal_inv (x)
% For each component of x, compute the quantile (the
% inverse of the CDF) at x of the standard normal distribution.

% Description: Quantile function of the standard normal distribution

%  Software version 1.0.1
%-------------------------------------------------------------------------------
% Copyright (C) 1995-2011 Kurt Hornik
% Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       KH <Kurt.Hornik@wu-wien.ac.at>
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

if (nargin ~= 1)
    error('Requires one input arguments.');
end

inv = sqrt (2) * erfinv (2 * x - 1);