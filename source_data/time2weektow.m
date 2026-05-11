function [week, sow] = time2weektow(time)

% SYNTAX:
%   [week, sow] = time2weektow(time);
%
% INPUT:
%   time = GPS time (continuous since 6-1-1980)
%
% OUTPUT:
%   week = GPS week
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

sec_in_week = 7*86400;

sow  = rem(time, sec_in_week);
week = (time - sow) / sec_in_week;