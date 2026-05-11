function setAllLinesColor(h, color)
% setAllLinesColor get all the lines handler and change their <color> value
%
% SINTAX:
%   setAllLinesColor(<h>,color)
%   setAllLinesColor(color)
%
% EXAMPLE:
%   setAllLinesColor(gcf,2);
%   setAllLinesColor(2);
%
% INPUT:
%   h       = handler to the figure to modify           <optional argument>
%   color   = requested color of all the lines
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
    color = h;
    h = gcf;
end
hline = findobj(h, 'type', 'line');
set(hline, 'Color', color);