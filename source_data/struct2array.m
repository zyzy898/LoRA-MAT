function vec_out = struct2array(struct_in)
% SYNTAX:
%   [vec_out] = struct2array(struct_in);
%
% INPUT:
%   struct_in = structure with fields of the same type
%
% OUTPUT:
%   vec_out = vectorized content of the struct
%
% DESCRIPTION:
%   Convert to a vector the fields of the structure in input
%   Note: It works only when the fields are of the same type

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

tmp = struct2cell(struct_in);
vec_out = [tmp{:}];