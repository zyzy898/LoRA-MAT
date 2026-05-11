function [out] = twos_complement(in)

% SYNTAX:
%   [out] = twos_complement(in)
%
% INPUT:
%   in = n-bit sequence in two's complement
%
% OUTPUT:
%   out = signed decimal value
%
% DESCRIPTION:
%   Two's complement to signed decimal

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

if in(1) =='1'                   %bit reversal
    for i = 1 : length(in)
        if in(i) == '1'
            out(i) = '0';
        else
            out(i) = '1';
        end
    end
    out = -fbin2dec(out) - 1;
else
    out = fbin2dec(in);
end