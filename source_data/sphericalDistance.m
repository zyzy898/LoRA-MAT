% SYNTAX:
%   dist = sphericalDistance(latd_a, lond_a, latd_b, lond_b);
%
% INPUT:
%   latd_a  = latitude of point a  [degree]
%   lond_a  = longitude of point a [degree]
%   latd_b  = latitude of point b  [degree]
%   lond_b  = longitude of point b [degree]
%
% OUTPUT:
%   dist = spherical distance in degrees
%
% DESCRIPTION:
%   Compute spherical distance among points (a or b can be an array)
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by: Andrea Gatti
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

function dist = sphericalDistance(latd_a, lond_a, latd_b, lond_b)
    dist = 2 * asind(sqrt(sind((latd_a - latd_b) / 2) .^2 + cosd(latd_a) .* cosd(latd_b) .* sind((lond_a - lond_b) / 2).^2));
end