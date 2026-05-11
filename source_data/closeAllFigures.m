function closeAllFigures(fig_handle)
% Close all the dockable figures
% App main windows are not dockable and will remain open ^_^
%
% SINTAX:
%   closeAllFigures(<fig_handles>);
%   closeAllFigures()
%
% EXAMPLE:
%   dockAllFigures();
%
% INPUT:
%   fig_handles = listo of handlers to the figure to close        <optional argument>
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
        delete(fig_handle);
    else
        all_fh = findall(0,'Type','figure');
        for fid = 1:length(all_fh)
            if (islogical(all_fh(fid).DockControls) && (all_fh(fid).DockControls == true)) || ...
               (ischar(all_fh(fid).DockControls) && (all_fh(fid).DockControls(2) == 'n')) || ...
               (isnumeric(all_fh(fid).DockControls) && (numel(all_fh(fid).DockControls) >= 2))
                delete(all_fh(fid));
            end
        end
    end
end