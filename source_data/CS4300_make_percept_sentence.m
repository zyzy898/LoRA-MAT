function sentence = CS4300_make_percept_sentence(percept,x,y)
% CS4300_make_percept_sentence - create logical sentence from percept
% On input:
% percept (1x5 Boolean vector): percept
% [Stench,Breeze,Glitter,Scream,Bump]
% x (int): x location of agent
% y (int): y location of agent
% On output:
% sentence (KB struct): logical sentence (CNF)
% (1).clauses (int): c1 (index of Sxy if stench), else -c1
% (2).clauses (int): c2 (index of Bxy if breeze), else -c2
% (3).clauses (int): c3 (index of Gxy if glitter), else -c3
% (4).clauses (int): c4 (index of Cxy if scream), else -c4
% (5).clauses (int): c5 (index of Exy if bump), else -c5
% Call:
% s = CS4300_make_percept_sentence([0,1,0,0,0],3,2);
% Author:
% Haochen Zhang & Tim Wei
% UU
% Fall 2017
%
% Pit: 1-16
% Glitter: 17-32
% Breeze: 33-48
% Stench: 49-64
% Wempus 65-80

sentence = [];

stench = 48 + x + 4 * (y - 1);
if percept(1)
    sentence(1) = stench;
else
    sentence(1) = -stench;
end

breeze = 32 + x + 4 * (y - 1);
if percept(2)
    sentence(2) = breeze;
else
    sentence(2) = -breeze;
end

glitter = 16 + x + 4 * (y - 1);
if percept(3)
    sentence(3) = glitter;
else
    sentence(3) = -glitter;
end

if percept(4)
    sentence(4) = 81;
else
    sentence(4) = -81;
end
