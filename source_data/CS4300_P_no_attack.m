function P = CS4300_P_no_attack(i,a,j,b)

P = 1;
xi = mod(i,4);
if ~xi
    xi = 4;
end
yi = floor((i-1) / 4 + 1);

xj = mod(j,4);
if ~xj
    xj = 4;
end
yj = floor((j-1) / 4 + 1);

neighbour = 0;
if xi == xj
    if yi ~= yj + 1 || yi ~= yj - 1
        neighbour = 1;
    end
end
if yi == yj
    if xi == xj + 1 || xi == xj - 1
        neighbour = 1;
    end
end

if ~neighbour
    return;
end

switch a
    case 1
    case 2
        if b ~= 3
            P = 0;
        end
    case 3
end
