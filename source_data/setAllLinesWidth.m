function setAllLinesWidth(h, width)
% setAllLinesWidth get all the lines handler and change them to a <width> value
%
% SINTAX:
%   setAllLinesWidth(<h>,width)
%   setAllLinesWidth(width)
%
% EXAMPLE:
%   setAllLinesWidth(gcf,2);
%   setAllLinesWidth(2);
%
% INPUT:
%   h       = handler to the figure to modify           <optional argument>
%   width   = requested width of all the lines
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
    width = h;
    h = gcf;
end
hline = findobj(h, 'type', 'line');
set(hline, 'LineWidth', width);