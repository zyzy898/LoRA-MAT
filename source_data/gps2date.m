function [date, doy, dow] = gps2date(gps_week, gps_sow)

% SYNTAX:
%   [date, doy, dow] = gps2date(gps_week, gps_sow);
%
% INPUT:
%   gps_week = GPS week
%   gps_sow  = GPS seconds of week
%
% OUTPUT:
%   date = date [year month day hour min sec]
%   doy  = day of year
%   dow  = day of week
%
% DESCRIPTION:
%   Conversion from GPS time to calendar date and day of year (DOY).

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

gps_start_datenum = 723186; %This is datenum([1980,1,6,0,0,0])

gps_dow = fix(gps_sow/86400);                             %day of week
date = datevec(gps_start_datenum + 7*gps_week + gps_dow); %calendar date up to days
gps_sod = gps_sow - gps_dow*86400;                        %seconds of day
date(:,4) = floor(gps_sod/3600);                          %hours
date(:,5) = floor(gps_sod/60 - date(:,4)*60);             %minutes
date(:,6) = gps_sod - date(:,4)*3600 - date(:,5)*60;      %seconds

%day of year (DOY)
if (nargout > 1)
    doy = date2doy(datenum(date));
    doy = floor(doy);
end

%day of week
if (nargout > 2)
    dow = gps_dow;
end