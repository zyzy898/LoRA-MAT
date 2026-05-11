function [X,Y,Z] = geod2cart (phi, lam, h, a, f)

% SYNTAX:
%   [X,Y,Z] = geod2cart (phi, lam, h, a, f);
%
% INPUT:
%   phi     = geodetic latitude                  [rad]
%   lam     = geodetic longitude                 [rad]
%   h       = ellipsoid height                   [m]
%   a       = ellipsoid semi-major axis          [m]
%   f       = ellipsoid flattening
%
% OUTPUT:
%   X       = X cartesian coordinate
%   Y       = Y cartesian coordinate
%   Z       = Z cartesian coordinate
%
% DESCRIPTION:
%   Conversion from geodetic to geocentric cartesian coordinates.

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

if (nargin == 3)
    cc = Constellation_Collector('G');
    a = cc.gps.ELL_A;
    e = cc.gps.ELL_E;
    e2 = e^2;
else
    e = sqrt(1-(1-f)^2);
    e2 = 1 - (1 - f)^2;
end
N = a ./ sqrt(1 - e2 * sin(phi).^2);

X = (N + h) .* cos(lam) .* cos(phi);
Y = (N + h) .* sin(lam) .* cos(phi);
Z = (N * (1 - e2) + h) .* sin(phi);