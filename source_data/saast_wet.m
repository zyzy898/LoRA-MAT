function [ZWD] = saast_wet(T, H, h)

% SYNTAX:
%   [ZWD] = saast_wet(T, H, h);
%
% INPUT:
%   T = air temperature
%   H = humidity
%   h = orthometric height
%
% OUTPUT:
%   ZWD = Zenith Wet Delay
%
% DESCRIPTION:
%   Zenith Wet Delay (ZWD) computation by Saastamoinen model.

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

% Convert C -> K
T = T + 273.15;

%height correction
H = H * exp(-0.0006396 * h);

% Convert humidity
H = H./100;

c = -37.2465 + 0.213166 * T - 2.56908 * (10^-4) * (T.^2);
e = H .* exp(c);

%ZWD (Saastamoinen model)
ZWD = 0.0022768 * (((1255 ./ T) + 0.05) .* e);