function [y] = local2globalVel2(V, lon,lat)

% SYNTAX:
%   [y] = local2globalVel2(V, X);
%
% INPUT:
%   V = local position vector(s)
%   lon = longitude of orifin vector in radians
%   lat = latirude of orifin vector in radians
%
% OUTPUT:
%   y = global position vector(s)
%
% DESCRIPTION:
%   Rototation from local-level reference frame to Earth-fixed reference frame

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

%initialize new position vector
y = zeros(size(V));

for i = 1 : size(V,2)
    %rotation matrix from global to local reference system
    R = [-sin(lon) cos(lon) 0;
         -sin(lat)*cos(lon) -sin(lat)*sin(lon) cos(lat);
         +cos(lat)*cos(lon) +cos(lat)*sin(lon) sin(lat)];

    %rototraslation
    y(:,i) = R\V(:,i);
end