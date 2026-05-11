function setAllMarkersSize(h, marker_size)
% setAllMarkersSize get all the lines handler and change their <marker_size> value
%
% SINTAX:
%   setAllMarkersSize(<h>,marker_size)
%   setAllMarkersSize(marker_size)
%
% EXAMPLE:
%   setAllMarkersSize(gcf,2);
%   setAllMarkersSize(2);
%
% INPUT:
%   h       = handler to the figure to modify           <optional argument>
%   marker_size   = requested marker_size of all the markers
%
% DEFAULT VALUES:
%   h       = gcf
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

if nargin < 2
    marker_size = h;
    h = gcf;
end
hline = findobj(h, 'type', 'line');
set(hline, 'MarkerSize', marker_size);