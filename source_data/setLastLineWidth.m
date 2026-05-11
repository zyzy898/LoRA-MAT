function setLastLineWidth(h,width)
% setLastLineWidth get the last lines handler and change them to a <width> value
%
% SINTAX:
%   setLastLineWidth(<h>,width)
%   setLastLineWidth(width)
%
% EXAMPLE:
%   setLastLineWidth(gca,2);
%   setLastLineWidth(2);
%
% INPUT:
%   h       = handler to the axes to modify           <optional argument>
%   width   = requested width of the last lines
%
% DEFAULT VALUES:
%   h       = gcf
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

if nargin < 2
    width = h;
    h = gcf;
end
hline = findobj(h, 'type', 'line');
set(hline(1), 'LineWidth', width);