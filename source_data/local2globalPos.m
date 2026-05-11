function [y] = local2globalPos(x, X)

% SYNTAX:
%   [y] = local2globalPos(x, X);
%
% INPUT:
%   x = local position vector(s)
%   X = origin vector(s)
%
% OUTPUT:
%   y = global position vector(s)
%
% DESCRIPTION:
%   Rototraslation from local-level reference frame to Earth-fixed reference frame

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

%initialize new position vector
y = zeros(size(x));

for i = 1 : size(X,2)

    %geodetic coordinates
    [phi, lam] = cart2geod(X(1,i), X(2,i), X(3,i));

    %rotation matrix from global to local reference system
    R = [-sin(lam) cos(lam) 0;
         -sin(phi)*cos(lam) -sin(phi)*sin(lam) cos(phi);
         +cos(phi)*cos(lam) +cos(phi)*sin(lam) sin(phi)];

    %rototraslation
    y(:,i) = R\x(:,i) + X(:,i);
end