function serialized_mat = serializeCell(cell)
% SYNTAX:
%   serialized_mat = serializeCell(mat)
% DESCRIPTION:
%   return the array of the serialized cell

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Giulio Tagliaferro
%  Contributors:     Giulio Tagliaferro ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    serialized_mat = [];
    for i = 1 : numel(cell)
    serialized_mat = [serialized_mat; serialize(cell{i})];
    end
end