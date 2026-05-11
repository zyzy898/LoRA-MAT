function [sow] = weektime2tow(week, time)

% SYNTAX:
%   [sow] = weektime2tow(week, time);
%
% INPUT:
%   week = GPS week
%   time = GPS time (continuous since 6-1-1980)
%
% OUTPUT:
%   sow  = GPS seconds-of-week
%
% DESCRIPTION:
%   Conversion from GPS time in continuous format (similar to datenum) to
%   GPS time in week, seconds-of-week.

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

sow = time - week*7*86400;