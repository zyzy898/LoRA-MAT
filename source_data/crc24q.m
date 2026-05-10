function [parity] = crc24q(msg)

% SYNTAX:
%   [parity] = crc24q(msg);
%
% INPUT:
%   msg = binary message
%
% OUTPUT:
%   parity = crc parity (24 bits)
%
% DESCRIPTION:
%   Applies CRC-24Q QualComm algorithm.

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:
%  Contributors:     ...
% ('rtcm3torinex.c', by Dirk Stoecker, BKG Ntrip Client (BNC) Version 1.6.1
%  was used as a reference)
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

parity = uint32(0);

%check the length of the input string, in case make it splittable byte-wise
remainder = rem(length(msg),8);
if (remainder ~= 0)
    fill = char(ones(1,8-remainder)*48); %fill string of zeroes
    msg = [fill msg];
end

Nbits = length(msg);

%pre-allocate to increase speed
Nbytes = Nbits / 8;
bytes = cell(1,Nbytes);
k = 1;
for j = 1 : 8 : Nbits
    bytes{k} = msg(j:j+7);
    k = k + 1;
end
%call 'fbin2dec' and 'bitshift' only once (to optimize speed)
bytes = bitshift(fbin2dec(bytes), 16);
bytes = uint32(bytes);
for i = 1 : Nbytes
    parity = bitxor(parity, bytes(i));
    for j = 1 : 8
        parity = bitshift(parity, 1);
        if bitand(parity, 16777216)
            parity = bitxor(parity, 25578747);
        end
    end
end

parity = dec2bin(parity, 24);