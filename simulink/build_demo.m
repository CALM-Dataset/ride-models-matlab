function file = build_demo(vehicle)
if nargin < 1
    vehicle = 'halfcar';
end
here = fileparts(mfilename('fullpath'));
addpath(here);
addpath(fullfile(here, '..', 'src'));
mdl = ['ride_demo_' vehicle];
file = fullfile(here, [mdl '.slx']);
if bdIsLoaded(mdl)
    close_system(mdl, 0);
end
if isfile(file)
    delete(file);
end
build_harness(mdl, vehicle);
set_param(mdl, 'InitFcn', demo_inputs_code(vehicle));
for scope = {'Body', 'Speed'}
    config = get_param([mdl '/' scope{1}], 'ScopeConfiguration');
    config.OpenAtSimulationStart = true;
end
save_system(mdl, file);
close_system(mdl, 0);
fprintf('wrote %s\n', file);
end

function code = demo_inputs_code(vehicle)
code = strjoin({
    'if isempty(which(''ride.run''))'
    '    run(fullfile(fileparts(get_param(bdroot, ''FileName'')), ''..'', ''setup.m''));'
    'end'
    'if ~exist(''ride_road'', ''var'') || ~exist(''ride_speeds'', ''var'')'
    sprintf('    ride_demo_run = ride.run(ride.config(''model'', ''%s''));', vehicle)
    '    ride_road = ride_demo_run.road;'
    '    ride_speeds = ride_demo_run.speeds;'
    '    ride_dt = ride_demo_run.P.DT;'
    '    ride_dt_sim = ride_demo_run.P.DT_SIM;'
    '    clear ride_demo_run'
    'end'}, newline);
end
