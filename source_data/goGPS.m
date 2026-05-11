function goGPS(ini_settings)
% SYNTAX:
%   goGPS;
%
% DESCRIPTION:
%   function launcher for goGPS
%   
% OUTPUT:
%   goGPS creates a singleton object, for debug purposes it is possible to obtain it typing:
%   core = Core.getInstance();
%
% EXAMPLE:
%   goGPS;
%
% COMPILATION STRING:
%   tic; mcc -v -d ./bin/ -m goGPS -a tai-utc.dat -a cls.csv -a icpl.csv -a nals.csv -a napl.csv -a remote_resource.ini -a credentials.txt -a app_settings.ini -a icons/*.png -a utility/thirdParty/guiLayoutToolbox/layout/+uix/Resources/*.png; toc;

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

% if the plotting gets slower than usual, there might be problems with the
% Java garbage collector. In case, you can try to use the following
% command:
%
% java.lang.System.gc() %clear the Java garbage collector
%
% or:
%
% clear java

%% Preparing execution and settings

    % add all the subdirectories to the search path
    addPathGoGPS;

    log = Logger.getInstance();
    log.disableFileOut();       

    log.enableGUIOut();
    log.disableScreenOut();
    Core.getMsgGUI(true);
    log.setColorMode(App_Settings.getInstance.isLogColorMode);


    % Show coloured header
    cm = log.getColorMode();
    log.setColorMode(true);    
    Core_UI.showTextHeader();
    log.setColorMode(cm);

    if nargin >= 1 && ~isempty(ini_settings)
        core = Core.getInstance(true, false, ini_settings);    
    else
        if Core.isNew()
            core = Core.getInstance(true, false); % Init Core
        else
            state = Core.getCurrentSettings();
            core = Core.getInstance(true, false, state); % Init Core
        end
    end
    
    if ~core.isValid
        log.addError('Nothing to do, core is not valid');
        return
    end

    ui = Core_UI.getInstance();
    flag_wait = true;
    ui.openGUI(flag_wait);
    Core_UI.isHideFig(false);

    if ~ui.isGo()
        return
    end

    % Enable file logging
    if core.state.isLogOnFile()
        log.newLine();
        log.enableFileOut();
        log.setOutFile(fullfile(core.state.getOutDir, 'log', sprintf('goGPS_run_%s_${NOW}.log', strrep(core.state.getPrjName, ' ', '_')))); % <= to enable project logging
        % log.setOut File(); <= to enable system logging (save into system folder)
        log.disableFileOut();
        fnp = File_Name_Processor();
        log.simpleSeparator()
        log.addMarkedMessage(sprintf('Logging to: "%s"\n', fnp.getRelDirPath(log.getFilePath, core.state.getHomeDir)));
        log.simpleSeparator()
        log.enableFileOut();
        log.addMessageToFile(Core_UI.getTextHeader());
        core.logCurrentSettings();
    end
    
    core.prepareProcessing(); % download important files
    core.go(); % execute all

    % Stop logging
    if core.state.isLogOnFile()
        log.disableFileOut();
        log.closeFile();
    end

    if ~isdeployed
        % Do not export to workspace
        %log.addMessage('Execute the script "getResults", to load the object created during the processing');

        % Export into workspace
        rec = core.rec;
        try
            coo = rec.getCoo;
        catch
            coo = Coordinates;
        end

        assignin('base', 'core', core);
        assignin('base', 'rec', rec);
        assignin('base', 'coo', coo);
        
        log.addMarkedMessage('Now you should be able to see 3 variables in workspace:');
        log.addMessage(log.indent(' - core      the core processor object containing all the goGPS data'));
        log.addMessage(log.indent(' - rec       the array of Receivers'));
        log.addMessage(log.indent(' - coo       the array of coordinates (rec.getCoo)'));

        screen_log = log.isScreenOut;
        if ~screen_log; log.enableScreenOut(); end
        log.simpleSeparator();
        log.addStatusOk(['Execution completed at ' GPS_Time.now.toString('yyyy/mm/dd HH:MM:SS') '      ^_^']);       
        log.simpleSeparator();
        if ~screen_log; log.disableScreenOut(); end
    end

    goInspector;    
end