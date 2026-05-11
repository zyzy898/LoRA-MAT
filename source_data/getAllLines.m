function hline = getAllLines(h)
% getAllLines get all the lines handler and change their <marker_size> value
%
% SINTAX:
%   h_list = getAllLines(<h>)
%
% EXAMPLE:
%   h_list = getAllLines(gcf);
%
% INPUT:
%   h       = handler to the figure to modify           <optional argument>
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

if nargin < 1
    h = gcf;
end
hline = findobj(h, 'type', 'line');