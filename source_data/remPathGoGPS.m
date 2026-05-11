function remPathGoGPS()
% Script to remove goGPS folders to path with black_list

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti, ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    if ~isdeployed
       addPathGoGPS(true);
    end
end