function [y] = local2globalVel(V, X)

% SYNTAX:
%   [y] = local2globalVel(V, X);
%
% INPUT:
%   V = local position vector(s)
%   X = origin vector(s)
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

for i = 1 : size(X,2)

    %geodetic coordinates
    [phi, lam] = cart2geod(X(1,i), X(2,i), X(3,i));

    %rotation matrix from global to local reference system
    R = [-sin(lam) cos(lam) 0;
         -sin(phi)*cos(lam) -sin(phi)*sin(lam) cos(phi);
         +cos(phi)*cos(lam) +cos(phi)*sin(lam) sin(phi)];

    %rototraslation
    y(:,i) = R\V(:,i);
end