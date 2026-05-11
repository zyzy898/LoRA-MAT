function ax = setXLim(fh, new_lim, axis_id)
% Set the X limits to all the axis of a figure
%
% INPUT
%   fh       figurehandle
%   new_lim  new limits for X axis
%   axis_id  number of the axis (1 is the first inserted)
%
% SYNTAX
%   setXLim(fh, new_line, axis_id)
%   setXLim(new_line, axis_id)
%   setXLim(fh, new_line)
%   setXLim(new_line)

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:        Andrea Gatti
%  Contributors:      ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    if nargin <= 2
        axis_id = [];
    end
    if not(isa(fh, 'matlab.ui.Figure'))
        if nargin == 2
            axis_id = new_lim;
        end
        new_lim = fh;
        fh = gcf;
    end
    set(0, 'CurrentFigure', fh);
    if isempty(axis_id)
        for a = 1 : numel(fh.Children)
            if isa(fh.Children(a), 'matlab.graphics.axis.Axes')
                subplot(fh.Children(a));
                xlim(new_lim);
            end
        end
    else
        try
            ax = fh.Children(max(1, end + 1 - axis_id));
            subplot(ax);
            xlim(new_lim);
        catch
            ax = axes();
        end
    end
end