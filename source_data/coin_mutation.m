function [ offspring ] = coin_mutation(population,popSize,geneLength, mutationRate)
%COIN_MUTATION Summary of this function goes here
%   Detailed explanation goes here

offspring(1:popSize)=struct('g',{[zeros(1,geneLength)]},'f',[0]);
%% Mutation
for x = 1:popSize                           %for all offspring
    for y = 1:geneLength                    %for each gene
        z=rand(1);                      %flip a coin completely random(like drawing from Gauss distribution?)
        if z < mutationRate                 %implements the probability
            if offspring(x).g(y)==1;        %flip the gene
                offspring(x).g(y) = 0;
            else
                offspring(x).g(y) = 1;
            end
            
        end
    end
end

end

