function KB_out = CS4300_Tell(KB,sentence)
% CS4300_Tell - Tell function for logic KB
% On input:
% KB (KB struct): Knowledge base (CNF)
% (k).clauses (1xp vector): disjunction clause
% sentence (KB struct): query theorem (CNF)
% (k).clauses (1xq vector): disjunction
% On output:
% KB_out (KB struct): revised KB
% Call:
% KB = CS4300_Tell([],[1]);
% Author:
% Haochen Zhang & Tim Wei
% UU
% Fall 2017
%

for clause = sentence
    
    if length(clause) == 1
        if clause == 81
            % scream - remove all clauses about wampus/stench from KB and
            %           put in knowledge of ~W for all x and y.
            for i = length(KB):-1:1
                KB_clause = KB(i).clauses;
                if any(abs(KB_clause) > 48)
                    KB(i) = [];
                end
            end
            for i = 65:80
                KB(end + 1).clauses = i;
            end
        else 
            % if there are clauses contains only one symbol and the symbol
            % is the same as the clause TELLed, keep the new TELLed one.
            for i = length(KB):-1:1
                KB_clause = KB(i).clauses;
                if length(KB_clause) == 1 && abs(clause) == abs(KB_clause)
                    KB(i) = [];
                end
            end
        end
    end
    if ~any(abs(clause) == 81)
        % always add the new clause in except for scream
        KB(end + 1).clauses = clause;
    end
end

KB_out = KB;
