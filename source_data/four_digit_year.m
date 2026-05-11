function [year_out] = four_digit_year(year_in)

% SYNTAX:
%   [year_out] = four_digit_year(year_in);
%
% INPUT:
%   year_in = two-digit year
%
% OUTPUT:
%   year_out = four-digit year
%
% DESCRIPTION:
%   Conversion of two-digit year values to four-digit year values
%   (following RINEX2 standard).

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

year_out = year_in + 2000;
year_out(year_out >= 2079) = year_out(year_out >= 2079) - 100;