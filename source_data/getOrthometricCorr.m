function N = getOrthometricCorr(phi, lam, geoid, method)
% SYNTAX:
%   N = getOrthometricCorr(phi, lam, geoid);
%
% EXAMPLE:
%   geoid = Core.getRefGeoid();
%   getOrthometricCorr(45.69 ./ 180*pi, 9.03 ./ 180*pi, geoid, 'legacy')
%   % or
%   getOrthometricCorr(45.69, 9.03, geoid, 'grid')
%   % answer should be 46.1837532
%
% INPUT:
%   phi     = geodetic latitude                [deg (rad for legacy method)]
%   lam     = geodetic longitude               [deg (rad for legacy method)]
%   geoid   = regular map in geocentric coordinates <default = EGM08 0.5x0.5 deg>
%   method  = interpolation approach:
%              - legacy
%              - grid
%              - grid_cubic  ( phi, lam are array of grid coordinates )
%              - grid_akima  ( phi, lam are array of grid coordinates )
%              - linear
%              - natural
%
% OUTPUT:
%   N       = geoid ondulation [m]
%
% DESCRIPTION:
%   Get the geoid ondulation (orthometric correction)

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti, Daniele Sampietro
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

if (nargin < 3) || isempty(geoid)
    geoid = Core.getRefGeoid();
end
if (nargin < 4) || isempty(method)
    method = 'legacy';
end

if  (geoid.ncols == 0 || geoid.nrows == 0) 
    Core.initGeoid();
    geoid = Core.getRefGeoid();
end
N = zeros(numel(lam), 1);

switch method
    case 'legacy'
        for i = 1 : numel(lam)
            N(i) = grid_bilin_interp(lam(i) / pi * 180, phi(i) / pi * 180, geoid.grid, geoid.ncols, geoid.nrows, geoid.cellsize, geoid.Xll, geoid.Yll, -9999);            
        end
    case 'grid'
        x_grid = geoid.Xll + geoid.cellsize * (0 : geoid.ncols - 1);
        y_grid = fliplr(geoid.Yll + geoid.cellsize * (0 : geoid.nrows - 1));
        
        [xmg, ymg] = meshgrid(x_grid, y_grid);
        N = interp2(xmg, ymg, geoid.grid, lam, phi, 'linear');
    case 'grid_cubic'
        x_grid = geoid.Xll + geoid.cellsize * (0 : geoid.ncols - 1);
        y_grid = fliplr(geoid.Yll + geoid.cellsize * (0 : geoid.nrows - 1));
        
        [xmg, ymg] = meshgrid(x_grid, y_grid);
        N = interp2(xmg, ymg, geoid.grid, lam, phi, 'cubic');
    case 'grid_akima'
        x_grid = geoid.Xll + geoid.cellsize * (0 : geoid.ncols - 1);
        y_grid = fliplr(geoid.Yll + geoid.cellsize * (0 : geoid.nrows - 1));
        
        [xmg, ymg] = meshgrid(x_grid, y_grid);
        N = interp2(xmg, ymg, geoid.grid, lam, phi, 'makima');
    case 'linear'
        x_grid = geoid.Xll + geoid.cellsize * (0 : geoid.ncols - 1);
        y_grid = fliplr(geoid.Yll + geoid.cellsize * (0 : geoid.nrows - 1));
        [xmg, ymg] = meshgrid(x_grid, y_grid);
        finterp = scatteredInterpolant(xmg(:), ymg(:), geoid.grid(:), 'linear');
        
        N = finterp(lam, phi);        
    case 'natural'
        x_grid = geoid.Xll + geoid.cellsize * (0 : geoid.ncols - 1);
        y_grid = fliplr(geoid.Yll + geoid.cellsize * (0 : geoid.nrows - 1));
        
        [xmg, ymg] = meshgrid(x_grid, y_grid);
        finterp = scatteredInterpolant(xmg(:), ymg(:), geoid.grid(:), 'natural');        
        N = finterp(lam, phi);
end