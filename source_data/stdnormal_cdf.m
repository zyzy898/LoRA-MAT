function cdf = stdnormal_cdf (x)
% For each component of x, compute the CDF of the standard normal
% distribution at x.

% Description: CDF of the standard normal distribution

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

if (numel(x) == 0)
    error ('stdnormal_cdf: X must not be empty');
end

cdf = erfc(real(x) / (-sqrt(2))) / 2;