function [phi_grid, lambda_grid] = getGrid(step, phi_min, phi_max, lambda_min, lambda_max)
%  Get the array of knots of the grid
%
% INPUT:
%   step:   step of the grid
%   ...     limits of the grid
%
% OUTPUT:
%   phiGrid    = array of knots of the grid (phi) as
%                phiMax - step/2 : -step : phiMin + step / 2;
%   lambdaGrid = array of knots of the grid (lambda) as
%                lambdaMin + step / 2 : step : lambdaMax - step / 2;
%
% SYNTAX:
%   [phi_grid, lambda_grid] = getGrid(step, phi_min, phi_max, lambda_min, lambda_max)

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2011 Andrea Gatti
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti, ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    if nargin == 1
        phi_min = -90;
        phi_max = 90;
        lambda_min = -180;
        lambda_max = 180;
    end

    if phi_min > phi_max
        tmp = phi_min;
        phi_min = phi_max;
        phi_max = tmp;
    end

    if lambda_min > lambda_max
        tmp = lambda_min;
        lambda_min = lambda_max;
        lambda_max = tmp;
    end
    
    phi_grid = (phi_max - step(1)/2 : -step(1) : phi_min + step(1) / 2)';
    lambda_grid = (lambda_min + step(end) / 2 : step(end) : lambda_max - step(end) / 2)';
end