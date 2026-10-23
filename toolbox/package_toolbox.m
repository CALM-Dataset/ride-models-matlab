function file = package_toolbox()
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'src'), fullfile(root, 'simulink'));
version = strtrim(fileread(fullfile(root, 'VERSION')));
build_ride_lib();
opts = matlab.addons.toolbox.ToolboxOptions(root, '26c9b70e-16ef-48ad-b881-63dc000d2aed');
opts.ToolboxName = 'Ride Models';
opts.ToolboxVersion = version;
opts.Summary = 'Quarter-car and half-car ride models with road scenarios, speed profiles, comfort metrics and an animated view.';
opts.Description = ['Simulate a car over bumps, holes and measured roads, score the ride with ISO 2631-1 ', ...
    'weighted acceleration, and watch it. Models, scenarios, speed profiles and metrics are plug-ins. ', ...
    'Includes a Simulink library with the same models.'];
opts.AuthorName = 'Mohammed El Said Azab Abdelazim';
opts.MinimumMatlabRelease = 'R2025b';
opts.ToolboxMatlabPath = {fullfile(root, 'src'), fullfile(root, 'simulink')};
opts.ToolboxFiles = toolbox_files(root);
if ~isfolder(fullfile(root, 'dist'))
    mkdir(fullfile(root, 'dist'));
end
file = fullfile(root, 'dist', ['ride-models-' version '.mltbx']);
opts.OutputFile = file;
matlab.addons.toolbox.packageToolbox(opts);
fprintf('wrote %s\n', file);
end

function files = toolbox_files(root)
folders = {'config', 'data', 'docs', 'examples', 'simulink', 'src', 'templates', 'tests'};
files = {};
for i = 1:numel(folders)
    found = dir(fullfile(root, folders{i}, '**', '*'));
    found = found(~[found.isdir]);
    files = [files, fullfile({found.folder}, {found.name})]; %#ok<AGROW>
end
skip = contains(files, [filesep 'cache' filesep]) | contains(files, [filesep 'slprj' filesep]) ...
    | endsWith(files, {'.asv', '.slxc', '.autosave', '.mp4', '.avi', '.DS_Store'}) ...
    | endsWith(files, fullfile('examples', 'validation', 'paths.json'));
files = [files(~skip), fullfile(root, {'README.md', 'LICENSE', 'CITATION.cff', 'VERSION', 'RELEASE_NOTES.md', 'setup.m'})];
end
