function setLastLineStyle(h, line_style)

% setLastLineStyle get all the lines handler and change them to a <linestyle> value
%
% SINTAX:
%   setLastLineStyle(<h>, line_style)
%   setLastLineStyle(line_style)
%
% EXAMPLE:
%   setLastLineStyle(gcf, ':');
%   setLastLineStyle(':');
%
% INPUT:
%   h          = handler to the figure to modify        <optional argument>
%   line_style = requested line style for the line
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
set(hline(1), 'LineStyle', line_style);