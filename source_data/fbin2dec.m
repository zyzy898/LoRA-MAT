function x=fbin2dec(s)
%FBIN2DEC (fast bin2dec) Convert binary string to decimal integer.
%   X = FBIN2DEC(B) interprets the binary string B and returns in X the
%   equivalent decimal number. It is a stripped version of "bin2dec", with
%   a minimal check on input.
%
%   If B is a character array, or a cell array of strings, each row is
%   interpreted as a binary string.
%
%   Example
%       fbin2dec('010111') returns 23

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

% handle input
s = char(s);

[m,n] = size(s);

% Convert to numbers
v = s - '0';
twos = pow2(n-1:-1:0);
x = sum(v .* twos(ones(m,1),:),2);