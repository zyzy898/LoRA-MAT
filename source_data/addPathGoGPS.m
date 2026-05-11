function addPathGoGPS(flag_rem)
% Script to add goGPS folders to path with black_list

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti, ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    if ~isdeployed
        p = genpath(pwd);

        % bin folder
        [l1, l2] = regexp(p,'(?<=:)[^:]*bin[\/|\\][^:]*:');

        for l = size(l1, 2) : -1 : 1
            p(l1(l) : l2(l)) = [];
        end

        [l1, l2] = regexp(p,'(?<=:)[^:]*bin[^:]*:');

        for l = size(l1, 2) : -1 : 1
            p(l1(l) : l2(l)) = [];
        end

        % GACOS folder
        [l1, l2] = regexp(p,'(?<=:)[^:]*20180416T085957[^:]*:');

        for l = size(l1, 2) : -1 : 1
            p(l1(l) : l2(l)) = [];
        end

        % GACOS folder
        [l1, l2] = regexp(p,'(?<=:)[^:]*GACOS[\/|\\]example[^:]*:');

        for l = size(l1, 2) : -1 : 1
            p(l1(l) : l2(l)) = [];
        end

        % SINERGY folder
        [l1, l2] = regexp(p,'(?<=:)[^:]*Sinergy[\/|\\]maps[^:]*:');

        for l = size(l1, 2) : -1 : 1
            p(l1(l) : l2(l)) = [];
        end

        % GIT folders
        [l1, l2] = regexp(p,'(?<=:)[^:]*\.git[^:]*:');

        for l = size(l1, 2) : -1 : 1
            p(l1(l) : l2(l)) = [];
        end

        % SVN folders
        [l1, l2] = regexp(p,'(?<=:)[^:]*\.svn[^:]*:');

        % LOG folders
        [l1, l2] = regexp(p,'(?<=:)[^:]*\log[^:]*:');
        
        for l = size(l1, 2) : -1 : 1
            p(l1(l) : l2(l)) = [];
        end
        
        if nargin == 1 && flag_rem
            rmpath(p);
        else
            addpath(p);
        end
    end
end