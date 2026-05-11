function [rx] = roundmod(x,y)

% SYNTAX:
%   [rx] = roundmod(x,y);
%
% INPUT:
%   x = values to be rounded
%   y = resolution
%
% OUTPUT:
%   rx = rounded values
%
% DESCRIPTION:
%   Rounds the input values to the nearest float determined by the
%   resolution in input.

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:
%  Contributors:     Andrea Gatti, ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

rx = round(x./y).*y;

% Does this piece of code make sense?
% This should do the same 10 times faster: rx = round(x./y).*y;
%
% remainder = mod(x,y);
% rx = zeros(size(remainder));
% pos1 = find(remainder<=y/2);
% pos2 = find(remainder>y/2);
% rx(pos1) = x(pos1) - remainder(pos1);
% rx(pos2) = x(pos2) - remainder(pos2) + y;