function dockAllFigures(fig_handle)
% Change the WindowStyle of all the figures to docked
%
% SINTAX:
%   dockAllFigures(<fig_handle>);
%   dockAllFigures()
%
% EXAMPLE:
%   dockAllFigures(gcf);
%
% INPUT:
%   fig_handle = handler to the figure to dock           <optional argument>
%
% DEFAULT VALUES:
%   fig_handle all the figures
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    if (nargin == 1)
        set(fig_handle,'WindowStyle','docked');
    else
        all_fh = findall(0,'Type','figure');
        for fig_handle = 1:length(all_fh)
            dc = all_fh(fig_handle).DockControls;
            if ischar(dc)
                dc = strcmp(dc, 'on');
            end
            if numel(all_fh(fig_handle).DockControls) == 2 || dc == true
                set(all_fh(fig_handle), 'WindowStyle', 'docked')
            end
        end
    end
end