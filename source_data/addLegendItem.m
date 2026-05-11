function [h, icons, plots, legend_text] = addLegendItem(item, pos)
% Add an item to the legend
% SYNTAX:
%   addLegendItem(<item>, <pos>);
%
% EXAMPLE:
%   addLegendItem("item", 2);;
%
% INPUT:
%   item = new entry
%   pos  = position in the list of inputs
%
% DEFAULT VALUES:
%   fig_handle = gcf;
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti, ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    l = legend; 
    outm = get(l,'String');
    if nargin == 1
        pos = numel(outm) + 1;
    end
    if isempty(outm)
        [h, icons, plots, legend_text] = legend(item, 'Location', 'eastoutside'); 
        n_entry = 1;
        icons = icons(n_entry + 2 : 2 : end);
    else
        outm{pos} = item;
        [h, icons] = legend(outm, 'Location', 'eastoutside');
        n_entry = numel(outm);
        icons = icons(n_entry + 2 : 2 : end);
    end
end