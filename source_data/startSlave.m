function startSlave(com_dir)
% SYNTAX:
%   startSlave(<com_dir>);
%
% INPUT:
%   com_dir       communication directory
%
% DESCRIPTION:
%   function launcher for app slaves
%
% EXAMPLE:
%   startSlave('../com');
%
% COMPILATION STRING:
%    tic; mcc -v -d ../bin/ -m startSlave -a tai-utc.dat -a cls.csv -a icpl.csv -a nals.csv -a napl.csv -a remote_resource.ini -a credentials.txt -a app_settings.ini -a icons/*.png -a utility/thirdParty/guiLayoutToolbox/layout/+uix/Resources/*.png -R -singleCompThread; toc;
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti, ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    if nargin == 1
        fprintf('Starting slave, my com dir is "%s"\n', com_dir);
        log = Logger.getInstance;
        log.setColorMode(0);
        %log.setVerbosityLev(0);
        gos = Go_Slave.getInstance(com_dir);
        gos.live;
        exit
    else
        fprintf('I need a parameter: com_dir\n');
    end
end