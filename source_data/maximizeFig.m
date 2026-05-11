function maximizeFig(fig_handle)
% Maximize the figure
% SYNTAX:
%   maximizeFig(<fig_handle>);
%
% EXAMPLE:
%   maximizeFig(gcf);
%
% INPUT:
%   fig_handle = handler to the figure to modify        <optional argument>
%
% DEFAULT VALUES:
%   fig_handle = gcf;
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

if nargin < 1
    fig_handle = gcf;
end
    set(fig_handle, 'units','normalized', 'outerposition',[0 0 1 1]);
%     try
%         if isa(fig_handle, 'matlab.ui.Figure')
%             fig_handle = get(fig_handle,'Number');
%         end
%         drawnow % Required to avoid Java errors
%         j_frame = get(fig_handle, 'JavaFrame');
%         j_frame.setMaximized(true);
%     catch
%         % no more supported :-(
%     end
end