% Shortcut to open the main settings editor of goGPS

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

addPathGoGPS
log = Core.getLogger();
log.setOutMode(0,[],1);
ui = Core_UI.getInstance();
flag_wait = false;
ui.openGUI(flag_wait);
