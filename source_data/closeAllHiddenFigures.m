function closeAllHiddenFigures(flag_dockable)
% Close all the hidden figures
% App main windows are not dockable and will remain open ^_^
%
% SINTAX:
%   closeAllHiddenFigures(<flag_dockable = false>);
%
% EXAMPLE:
%   dockAllFigures();
%
% INPUT:
%   flag_dockable = close also hidden dockable figures
%
% DEFAULT VALUES:
%   flag_dockable = false
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    if (nargin == 0) || isempty(flag_dockable)
        flag_dockable = false;
    end

    all_fh = findall(0,'Type','figure');
    for fid = 1:length(all_fh)
        if (~flag_dockable || ((islogical(all_fh(fid).DockControls) && (all_fh(fid).DockControls == true)) || ...
                (ischar(all_fh(fid).DockControls) && (all_fh(fid).DockControls(2) == 'n')) || ...
                (isnumeric(all_fh(fid).DockControls) && (numel(all_fh(fid).DockControls) >= 2)))) && ...
                all_fh(fid).Visible == false
            fprintf('Closing "%s"\n', all_fh(fid).Name);
            delete(all_fh(fid));
        end
    end
end