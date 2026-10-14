function package_toolbox(version)
if nargin < 1
    version = '1.0.0';
end
root = fileparts(fileparts(mfilename('fullpath')));
opts = matlab.addons.toolbox.ToolboxOptions(root, '26c9b70e-16ef-48ad-b881-63dc000d2aed');
opts.ToolboxName = 'Ride Models';
opts.ToolboxVersion = version;
opts.Summary = 'Quarter-car and half-car ride models with scenarios, speed profiles, comfort metrics and rendering.';
opts.Description = ['Simulate a car over bumps, holes and measured roads, score the ride, and watch it. ', ...
    'Models, scenarios, speed profiles and metrics are plug-ins.'];
opts.AuthorName = 'Mohammed El Said Azab Abdelazim';
opts.MinimumMatlabRelease = 'R2019b';
opts.ToolboxMatlabPath = {fullfile(root, 'src')};
found = dir(fullfile(root, '**', '*'));
found = found(~[found.isdir]);
paths = fullfile({found.folder}, {found.name});
skip = contains(paths, [filesep '.git' filesep]) | contains(paths, [filesep 'dist' filesep]) ...
    | contains(paths, [filesep 'cache' filesep]) | contains(paths, [filesep 'tests' filesep]) ...
    | endsWith(paths, {'.mp4', '.avi', '.asv', '.slxc'});
opts.ToolboxFiles = paths(~skip);
if ~isfolder(fullfile(root, 'dist'))
    mkdir(fullfile(root, 'dist'));
end
opts.OutputFile = fullfile(root, 'dist', ['ride-models-' version '.mltbx']);
matlab.addons.toolbox.packageToolbox(opts);
end
