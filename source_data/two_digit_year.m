function [year_out] = two_digit_year(year_in)

% SYNTAX:
%   [year_out] = two_digit_year(year_in);
%
% INPUT:
%   year_in = four-digit year
%
% OUTPUT:
%   year_out = two-digit year
%
% DESCRIPTION:
%   Conversion of four-digit year values to two-digit year values.

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

year_out = year_in - 2000;

year_out(year_out < 0) = year_out(year_out < 0) + 100;