function CNF = CS4300_literal_CNF(literal)
% CS4300_literal_CNF - make a literal into CNF
% On input:
% literal (double): literal to be turned into CNF
% On output:
% CNF: CNF form of the literal
% Call:
% c = CS4300_literal_CNF(-1);
% Author:
% Haochen Zhang & Tim Wei
% UU
% Fall 2017
%

CNF(1).clauses = literal;