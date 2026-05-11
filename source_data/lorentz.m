function [p] = lorentz(x,y)

% SYNTAX:
%   [p] = lorentz(x,y);
%
% INPUT:
%   x = vector of size 4x1
%   y = vector of size 4x1
%
% OUTPUT:
%   p = Lorentz inner product of the two 4x1 vectors
%
% DESCRIPTION:
%   Computation of the Lorentz inner product.

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) Kai Borre
%  Written by:       Kai Borre 04-22-95
%  Contributors:     Mirko Reguzzoni, Eugenio Realini, 2009
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

p = x(1)*y(1) + x(2)*y(2) + x(3)*y(3) - x(4)*y(4);