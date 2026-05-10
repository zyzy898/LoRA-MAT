function b = CS4300_Ask(KB,sentence)
% CS4300_Ask - Ask function for logic KB
% On input:
% KB (KB struct): Knowledge base (CNF)
% (k).clauses (1xp vector): disjunction clause
% sentence (KB struct): query theorem (CNF)
% (k).clauses (1xq vector): disjunction
% On output:
% b (Boolean): 1 if KB entails sentence, else 0
% Call:
% KB(1).clauses = [1];
% KB(2).clauses = [-1,2];
% sentence(1).clauses = [2];
% b = CS4300_Ask(KB,sentence);
% Author:
% Haochen Zhang & Tim Wei
% UU
% Fall 2017
%

[Sip,finished] = CS4300_RTP(KB, sentence, 1:80);
b = finished && isempty(Sip);