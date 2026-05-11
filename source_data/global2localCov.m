function [Cyy] = global2localCov(Cxx, X)

% SYNTAX:
%   [Cyy] = global2localCov(Cxx, X);
%
% INPUT:
%   Cxx = input covariance matrices
%   X   = position vectors
%
% OUTPUT:
%   Cyy = output covariance matrices
%
% DESCRIPTION:
%   Covariance propagation from Earth-fixed reference frame to local-level reference frame

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

%initialize new covariance matrices
Cyy = zeros(size(Cxx));

for i = 1 : size(X,2)

    %geodetic coordinates
    [phi, lam] = cart2geod(X(1,i), X(2,i), X(3,i));

    %rotation matrix from global to local reference system
    R = [-sin(lam) cos(lam) 0;
         -sin(phi)*cos(lam) -sin(phi)*sin(lam) cos(phi);
         +cos(phi)*cos(lam) +cos(phi)*sin(lam) sin(phi)];

    %covariance propagation
    Cyy(:,:,i) = R * Cxx(:,:,i) * R';
end

%----------------------------------------------------------------------------------------------