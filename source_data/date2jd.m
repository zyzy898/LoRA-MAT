function [jd, mjd] = date2jd(date)

% SYNTAX:
%   [jd, mjd] = date2jd(date);
%
% INPUT:
%   date = date [year, month, day, hour, min, sec]
%
% OUTPUT:
%   jd  = julian day
%   mjd = modified julian day
%
% DESCRIPTION:
%   Conversion from date to julian day and modified julian day.

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

year  = date(:,1);
month = date(:,2);
day   = date(:,3);
hour  = date(:,4);
min   = date(:,5);
sec   = date(:,6);

pos = (month <= 2);
year(pos)  = year(pos) - 1;
month(pos) = month(pos) + 12;

%julian day
jd = floor(365.25*(year+4716)) + floor(30.6001*(month+1)) + day + hour/24 + min/1440 + sec/86400 - 1537.5;

%modified julian day
mjd = jd - 2400000.5;