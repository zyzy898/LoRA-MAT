function rcm = getMeridianRadiusCurvature(lat_rad)
% get Earth meridian radius of curvature at geodetic latitude
% lat (radians), using GPS ellipsoid (WGS84)
% SYNTAX: 
%    rcm = getMeridianRadiusCurvature(lat_rad)


%  Software version 1.0.1
%-------------------------------------------------------------------------------
% Copyright (C) 2024 Geomatics Research & Development srl (GReD)
% Adapted from Octave
%  Written by: Giulio Tagliaferro
%  Contributors:     
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

a = GPS_SS.ELL_A;
e2 = GPS_SS.ELL_E2;
rcm = a * (1 - e2) / (1 - e2*sin(lat_rad)^2)^(3/2);
end