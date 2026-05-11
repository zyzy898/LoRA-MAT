function [gps_week, gps_sow, gps_dow] = jd2gps(jd)

% SYNTAX:
%   [gps_week, gps_sow, gps_dow] = jd2gps(jd);
%
% INPUT:
%   jd = julian day
%
% OUTPUT:
%   gps_week = GPS week
%   gps_sow  = GPS seconds of week
%   gps_dow  = GPS day of week
%
% DESCRIPTION:
%   Conversion of julian day number to GPS week and
%	seconds of week.

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

deltat = jd - 2444244.5;
gps_week = floor(deltat/7);
gps_dow  = floor(deltat - gps_week*7);
gps_sow  = (deltat - gps_week*7)*86400;