function [ZHD] = saast_dry(P, h, lat)

% SYNTAX:
%   [ZHD] = saast_dry(P, h, lat);
%
% INPUT:
%   P = atmospheric pressure [hPa]
%   h = orthometric height [m]
%   lat = latitude [deg]
%
% OUTPUT:
%   ZHD = Zenith Hydrostatic Delay
%
% DESCRIPTION:
%   Zenith Hydrostatic Delay (ZHD) computation by Saastamoinen model.

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

%ZHD (Saastamoinen model)
ZHD = 0.0022767 * P(:) .* (1 + 0.00266 * cosd(2*lat(:)) + 0.00000028 * h(:));