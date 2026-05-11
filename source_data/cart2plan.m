function [EAST, NORTH, h, utm_zone] = cart2plan(X, Y, Z)

% SYNTAX:
%   [EAST, NORTH, h, utm_zone] = cart2plan(X, Y, Z);
%
% INPUT:
%   X = X axis cartesian coordinate
%   Y = Y axis cartesian coordinate
%   Z = Z axis cartesian coordinate
%
% OUTPUT:
%   EAST = EAST coordinate
%   NORTH = NORTH coordinate
%   h = ellipsoidal height
%   utm_zone = UTM zone (example: '32 T')
%
% DESCRIPTION:
%   Conversion from cartesian coordinates to planimetric coordinates (UTM WGS84).

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

%coordinate transformation
[phi, lam, h] = cart2geod(X, Y, Z);

%projection to UTM
[EAST, NORTH, utm_zone] = geod2plan(phi, lam);