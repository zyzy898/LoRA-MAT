function ax = setAxis(fh, axis_id)
% Enabled a certain axis in the figure, update MATLAB curfigure status
% useful to reset the current axis in case of new plotting
% 
% INPUT
%   fh       figurehandle
%   axis_id  number of the axis (1 is the first inserted)
%
% SYNTAX
%   setAxis(fh, axis_id)

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by: Giulio Tagliaferro
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    if nargin == 0
        fh = gcf;
        axis_id = 1;
    elseif nargin == 1
        axis_id = 1;
    end
    
    if not(isa(fh, 'matlab.ui.Figure'))
        axis_id = fh;
        fh = gcf;
    end
    set(0, 'CurrentFigure', fh);
    ax_list = fh.Children;
    % filter Axes
    id_ax = false(numel(ax_list),1);
    for a = 1:numel(ax_list)
        id_ax(a) = isa(ax_list(a), 'matlab.graphics.axis.Axes');
    end
    ax_list = ax_list(id_ax);
    try
        ax = ax_list(max(1, end + 1 - axis_id));
        subplot(ax);
    catch
        ax = axes();
    end
end