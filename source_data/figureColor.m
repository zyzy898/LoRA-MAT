function f = figureColor(n_col, varargin)
% Open figure, amnd set color order with the requested amount of colors
% To have multiple lines (in plot) of different colors!
% Using function Core_UI.getColor
%
% SYNTAX:
%   f = figureColor(n_col, <varargin>)
%
% EXAMPLE:
%   figureColor(200)
%
% INPUT:
%   n_col = maximum number of colors for the ColorOrder
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

if ~isempty(varargin)
    f = figure(varargin);
else
    f = figure;
end
ax = gca;
set(ax,'ColorOrder', Core_UI.getColor(1:n_col,n_col), 'NextPlot', 'replacechildren');