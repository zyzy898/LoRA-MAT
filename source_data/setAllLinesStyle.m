function setAllLinesStyle(h, line_style)
% setAllLinesStyle get all the lines handler and change them to a
% <line_style> value
%
% SINTAX:
%   setAllLinesStyle(<h>, line_style)
%   setAllLinesStyle(line_style)
%
% EXAMPLE:
%   setAllLinesStyle(gcf, ':');
%   setAllLinesStyle(':');
%
% INPUT:
%   h          = handler to the figure to modify        <optional argument>
%   line_style = requested style of all the lines
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
    line_style = h;
    h = gcf;
end
hline = findobj(h, 'type', 'line');
set(hline, 'LineStyle', line_style);