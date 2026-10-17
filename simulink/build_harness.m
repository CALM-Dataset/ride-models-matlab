function mdl = build_harness(mdl, vehicle)
here = fileparts(mfilename('fullpath'));
addpath(here);
addpath(fullfile(here, '..', 'src'));
if ~isfile(fullfile(here, 'ride_lib.slx'))
    build_ride_lib();
end
load_system(fullfile(here, 'ride_lib.slx'));
if bdIsLoaded(mdl)
    close_system(mdl, 0);
end
new_system(mdl);
set_param(mdl, 'SolverType', 'Fixed-step', 'Solver', 'ode4', 'FixedStep', 'ride_dt_sim', ...
    'StopTime', 'numel(ride_speeds) * ride_dt', 'ReturnWorkspaceOutputs', 'on', 'SaveTime', 'off', 'SaveOutput', 'off');
drive = put(mdl, 'ride_lib/Drive', 'Drive', [40 100 160 180], 'speeds', 'ride_speeds', 'dt', 'ride_dt');
front = put(mdl, 'ride_lib/Road', 'Road front', [260 60 360 120], 'road', 'ride_road', 'lag_m', '0');
switch vehicle
    case 'quartercar'
        car = put(mdl, 'ride_lib/Quarter-car', 'Quarter-car', [460 60 600 180]);
        wire(mdl, drive, 1, front, 1, 's');
        wire(mdl, drive, 2, front, 2, 'v');
        wire(mdl, front, 1, car, 1, 'zdot');
        logs = {'z_B_ddot', 1; 'z_W_ddot', 2; 'x', 3};
        scope_inputs = [1 2];
    case 'halfcar'
        P = ride.models.halfcar.params.load();
        rear = put(mdl, 'ride_lib/Road', 'Road rear', [260 160 360 220], 'road', 'ride_road', 'lag_m', num2str(P.L, 17));
        car = put(mdl, 'ride_lib/Half-car', 'Half-car', [460 60 600 260]);
        wire(mdl, drive, 1, front, 1, 's');
        wire(mdl, drive, 2, front, 2, 'v');
        wire(mdl, drive, 1, rear, 1);
        wire(mdl, drive, 2, rear, 2);
        wire(mdl, front, 1, car, 1, 'zdot_f');
        wire(mdl, rear, 1, car, 2, 'zdot_r');
        wire(mdl, drive, 3, car, 3, 'a_x');
        logs = {'z_B_ddot', 1; 'phi_ddot', 2; 'z_Wf_ddot', 3; 'z_Wr_ddot', 4; 'x', 5};
        scope_inputs = [1 2];
    otherwise
        error('ride:unknownModel', 'no Simulink block for model "%s", use quartercar or halfcar', vehicle);
end
for i = 1:size(logs, 1)
    y = 40 + 50 * (i - 1);
    sink = put(mdl, 'simulink/Sinks/To Workspace', ['log ' logs{i, 1}], [760 y 860 y + 30], ...
        'VariableName', logs{i, 1}, 'SaveFormat', 'Array', 'SampleTime', 'ride_dt');
    wire(mdl, car, logs{i, 2}, sink, 1, logs{i, 1});
end
scope = put(mdl, 'simulink/Sinks/Scope', 'Body', [760 320 800 380], 'NumInputPorts', num2str(numel(scope_inputs)));
config = get_param(scope, 'ScopeConfiguration');
config.LayoutDimensions = [numel(scope_inputs), 1];
for i = 1:numel(scope_inputs)
    wire(mdl, car, scope_inputs(i), scope, i);
end
speed_scope = put(mdl, 'simulink/Sinks/Scope', 'Speed', [260 280 300 320]);
wire(mdl, drive, 2, speed_scope, 1);
end
