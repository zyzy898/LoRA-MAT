function CtrlEnv_generateMarkdown
%% Generates Markdown files from Live Scripts

% Copyright 2024 The MathWorks, Inc.

generateMarkdown_fromLiveScript( ...
  LiveScriptFolderNames = [
  fullfile(currentProject().RootFolder, "Components", "ControllerAndEnvironment")
  fullfile(currentProject().RootFolder, "Components", "ControllerAndEnvironment", "SimulationCases")
  ], ...
  MarkdownFolderPath = ...
  fullfile(currentProject().RootFolder, "Components", "ControllerAndEnvironment", "markdown"), ...
  ForceExport = false )

end  % function
