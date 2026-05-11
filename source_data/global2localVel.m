function [y] = global2localVel(x, X)


% SYNTAX:
%   [y] = global2localPos(x, phi, lam);
%
% INPUT:
%   x = global velocity vector(s)
%   X = origin vector(s)
%
% OUTPUT:
%   y = local position vector(s)
%
% DESCRIPTION:
%   Rototraslation from Earth-fixed reference frame to local-level reference frame

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
phi=X(1)*pi/180;
lam=X(2)*pi/180;

for i = 1 : size(X,2)

    %geodetic coordinates
   % [phi, lam, h] = cart2geodvel(X(1,i), X(2,i), X(3,i)); %#ok<NASGU>

    %rotation matrix from global to local reference system
    R = [-sin(lam) cos(lam) 0;
         -sin(phi)*cos(lam) -sin(phi)*sin(lam) cos(phi);
         +cos(phi)*cos(lam) +cos(phi)*sin(lam) sin(phi)];

    %rototraslation
    y(:,i) = R * (x(:,i));
end

%----------------------------------------------------------------------------------------------