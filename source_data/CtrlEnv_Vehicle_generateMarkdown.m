function CtrlEnv_Vehicle_generateMarkdown
%% Generates Markdown files from Live Scripts

% Copyright 2024 The MathWorks, Inc.

generateMarkdown_fromLiveScript( ...
  LiveScriptFolderNames = [
  fullfile(currentProject().RootFolder, "Components", "ControllerAndEnvironment", "Harness", "Components", "Vehicle")
  fullfile(currentProject().RootFolder, "Components", "ControllerAndEnvironment", "Harness", "Components", "Vehicle", "SimulationCases")
  ], ...
  MarkdownFolderPath = ...
  fullfile(currentProject().RootFolder, "Components", "ControllerAndEnvironment", "Harness", "Components", "Vehicle", "markdown"), ...
  ForceExport = true )

end  % function
