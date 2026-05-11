function [phi, lam, h, phiC] = cart2geod(X, Y, Z)

% SYNTAX:
%   [phi, lam, h, phiC] = cart2geod(X, Y, Z);
%   [phi, lam, h, phiC] = cart2geod(xyz);
%
% INPUT:
%   X = X axis cartesian coordinate
%   Y = Y axis cartesian coordinate
%   Z = Z axis cartesian coordinate
%
% OUTPUT:
%   phi = latitude
%   lam = longitude
%   h = ellipsoidal height
%   phiC = geocentric latitude
%
% DESCRIPTION:
%   Conversion from cartesian coordinates to geodetic coordinates.

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

%global a_GPS e_GPS

if nargin == 1
    Z = X(:, 3);
    Y = X(:, 2);
    X = X(:, 1);
end

a = GPS_SS.ELL_A;
e = GPS_SS.ELL_E;

%radius computation
r = sqrt(X.^2 + Y.^2 + Z.^2);

%longitude
lam = atan2(Y,X);

%geocentric latitude
phiC = atan(Z./sqrt(X.^2 + Y.^2));

%coordinate transformation
psi = atan(tan(phiC)/sqrt(1-e^2));

phi = atan((r.*sin(phiC) + e^2*a/sqrt(1-e^2) * (sin(psi)).^3) ./ ...
    			(r.*cos(phiC) - e^2*a * (cos(psi)).^3));

N = a ./ sqrt(1 - e^2 * sin(phi).^2);

%height
h = r .* cos(phiC)./cos(phi) - N;