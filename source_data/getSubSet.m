function data = getSubSet(data, id_subset)
% SYNTAX
%   data = getSubSet(data, id_subset)
%
% DESCRIPTION
%   return the array with the given ids

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    data = data(id_subset);
end