function lib = build_ride_lib()
here = fileparts(mfilename('fullpath'));
addpath(fullfile(here, '..', 'src'));
lib = 'ride_lib';
if bdIsLoaded(lib)
    close_system(lib, 0);
end
file = fullfile(here, [lib '.slx']);
if isfile(file)
    delete(file);
end
new_system(lib, 'Library');
set_param(lib, 'Lock', 'off');
quarter = ride.models.quartercar.params.load();
half = ride.models.halfcar.params.load();
add_axle([lib '/Axle'], [40 40 160 140], axle_values(quarter));
save_system(lib, file);
set_param(lib, 'Lock', 'off');
add_quartercar([lib '/Quarter-car'], [220 40 360 160], quarter);
add_halfcar([lib '/Half-car'], [420 40 560 200], half);
add_road([lib '/Road'], [40 240 160 300]);
add_drive([lib '/Drive'], [220 240 360 320]);
set_param(lib, 'EnableLBRepository', 'on');
save_system(lib, file);
close_system(lib, 0);
fprintf('wrote %s\n', file);
end

function names = axle_parameter_names()
names = {'m_W', 'k_T', 'c_T', 'k_S', 'dz_S_stat', 'dz_cmp', 'dz_rbd', 'f1_cmp', 'f2_cmp', 'f1_rbd', 'f2_rbd', ...
    'F_max', 'D', 'A', 'v_d', 'v_z'};
end

function prompts = axle_parameter_prompts()
prompts = {'Wheel mass m_W [kg]', 'Tyre stiffness k_T [N/m]', 'Tyre damping c_T [N s/m]', ...
    'Spring stiffness k_S [N/m]', 'Static spring deflection dz_S_stat [m]', 'Compression knee dz_cmp [m]', ...
    'Rebound knee dz_rbd [m]', 'Compression shape f1_cmp [-]', 'Compression rate f2_cmp [-]', ...
    'Rebound shape f1_rbd [-]', 'Rebound rate f2_rbd [-]', 'Spring force limit F_max [N]', ...
    'Damper coefficient D [N s/m]', 'Damper asymmetry A [-]', 'Compression knee velocity v_d [m/s]', ...
    'Rebound knee velocity v_z [m/s]'};
end

function values = axle_values(p)
names = axle_parameter_names();
values = cell(size(names));
for i = 1:numel(names)
    values{i} = p.(names{i});
end
end

function add_axle(blk, position, values)
new_subsystem(blk, position);
in_zdot = put(blk, 'simulink/Sources/In1', 'zdot', [30 93 60 107]);
in_vc = put(blk, 'simulink/Sources/In1', 'v_corner', [30 353 60 367], 'Port', '2');
tyre_rate = put(blk, 'simulink/Math Operations/Sum', 'tyre rate', [130 85 150 115], 'Inputs', '+-', 'IconShape', 'round', 'ShowName', 'off');
tyre_defl = put(blk, 'simulink/Continuous/Integrator', 'tyre deflection', [210 80 240 120]);
k_T = put(blk, 'simulink/Math Operations/Gain', 'k_T', [300 85 350 115], 'Gain', 'k_T');
c_T = put(blk, 'simulink/Math Operations/Gain', 'c_T', [300 145 350 175], 'Gain', 'c_T');
F_t = put(blk, 'simulink/Math Operations/Sum', 'tyre force', [410 115 430 145], 'Inputs', '++', 'IconShape', 'round', 'ShowName', 'off');
net = put(blk, 'simulink/Math Operations/Sum', 'wheel force', [480 175 500 205], 'Inputs', '+-', 'IconShape', 'round', 'ShowName', 'off');
inv_m = put(blk, 'simulink/Math Operations/Gain', 'inverse wheel mass', [550 175 600 205], 'Gain', '1/m_W');
wheel_vel = put(blk, 'simulink/Continuous/Integrator', 'wheel velocity', [660 170 690 210]);
susp_rate = put(blk, 'simulink/Math Operations/Sum', 'suspension rate', [130 345 150 375], 'Inputs', '+-', 'IconShape', 'round', 'ShowName', 'off');
susp_defl = put(blk, 'simulink/Continuous/Integrator', 'suspension deflection', [210 290 240 330]);
k_S = put(blk, 'simulink/Math Operations/Gain', 'k_S', [300 275 350 305], 'Gain', 'k_S');
spring = put(blk, 'simulink/User-Defined Functions/MATLAB Function', 'progressive spring', [290 330 400 380], 'ShowName', 'off');
damper = put(blk, 'simulink/User-Defined Functions/MATLAB Function', 'damper', [290 410 400 460], 'ShowName', 'off');
F_s = put(blk, 'simulink/Math Operations/Sum', 'suspension force', [460 330 480 370], 'Inputs', '+++', 'IconShape', 'round', 'ShowName', 'off');
mux = put(blk, 'simulink/Signal Routing/Mux', 'state mux', [780 240 785 340], 'Inputs', '3', 'DisplayOption', 'bar', 'ShowName', 'off');
out_F = put(blk, 'simulink/Sinks/Out1', 'F_s', [860 403 890 417]);
out_acc = put(blk, 'simulink/Sinks/Out1', 'z_W_ddot', [860 93 890 107], 'Port', '2');
out_x = put(blk, 'simulink/Sinks/Out1', 'x', [860 283 890 297], 'Port', '3');
set_function(spring, spring_code(), {'k_S', 'dz_S_stat', 'dz_cmp', 'dz_rbd', 'f1_cmp', 'f2_cmp', 'f1_rbd', 'f2_rbd', 'F_max'});
set_function(damper, damper_code(), {'d1', 'z1', 'd2', 'z2', 'v_d', 'v_z'});
wire(blk, in_zdot, 1, tyre_rate, 1, 'zdot');
wire(blk, wheel_vel, 1, tyre_rate, 2);
wire(blk, tyre_rate, 1, tyre_defl, 1);
wire(blk, tyre_defl, 1, k_T, 1, 'x_T');
wire(blk, tyre_rate, 1, c_T, 1);
wire(blk, k_T, 1, F_t, 1);
wire(blk, c_T, 1, F_t, 2);
wire(blk, F_t, 1, net, 1, 'F_T');
wire(blk, F_s, 1, net, 2, 'F_S');
wire(blk, net, 1, inv_m, 1);
wire(blk, inv_m, 1, wheel_vel, 1, 'z_W_ddot');
wire(blk, inv_m, 1, out_acc, 1);
wire(blk, wheel_vel, 1, susp_rate, 1);
wire(blk, in_vc, 1, susp_rate, 2, 'v_corner');
wire(blk, susp_rate, 1, susp_defl, 1);
wire(blk, susp_defl, 1, k_S, 1, 'x_S');
wire(blk, susp_defl, 1, spring, 1);
wire(blk, susp_rate, 1, damper, 1);
wire(blk, k_S, 1, F_s, 1);
wire(blk, spring, 1, F_s, 2);
wire(blk, damper, 1, F_s, 3);
wire(blk, F_s, 1, out_F, 1);
wire(blk, tyre_defl, 1, mux, 1);
wire(blk, wheel_vel, 1, mux, 2, 'v_W');
wire(blk, susp_defl, 1, mux, 3);
wire(blk, mux, 1, out_x, 1, 'x');
note(blk, [30 20], 'SI units. x_T tyre deflection [m], x_S suspension deflection [m], v_W wheel velocity [m/s], F_T tyre force [N], F_S suspension force on the body [N].');
mask = Simulink.Mask.create(blk);
mask.Type = 'Axle';
mask.Description = ['One axle: tyre spring and damper, wheel mass, progressive suspension spring and ', ...
    'asymmetric damper. F_s is the suspension force on the body, positive upward. ', ...
    'x = [tyre deflection; wheel velocity; suspension deflection].'];
add_axle_parameters(mask, '', values, '');
mask.Initialization = 'c = ride.core.suspension.damper_coefficients(D, A); d1 = c.d1; z1 = c.z1; d2 = c.d2; z2 = c.z2;';
mask.Display = sprintf('port_label(''input'', 1, ''zdot'');\nport_label(''input'', 2, ''v_corner'');\nport_label(''output'', 1, ''F_s'');\nport_label(''output'', 2, ''z_W_ddot'');\nport_label(''output'', 3, ''x'');');
end

function add_axle_parameters(mask, prefix, values, container)
names = axle_parameter_names();
prompts = axle_parameter_prompts();
for i = 1:numel(names)
    args = {'Name', [prefix names{i}], 'Prompt', prompts{i}, 'Value', num2str(values{i}, 17), 'Evaluate', 'on', 'Tunable', 'on'};
    if ~isempty(container)
        args = [args, {'Container', container}]; %#ok<AGROW>
    end
    mask.addParameter(args{:});
end
end

function add_quartercar(blk, position, P)
new_subsystem(blk, position);
in_zdot = put(blk, 'simulink/Sources/In1', 'zdot', [20 63 50 77]);
axle = put(blk, 'ride_lib/Axle', 'axle', [120 50 220 150]);
inv_m = put(blk, 'simulink/Math Operations/Gain', 'inverse body mass', [300 75 350 105], 'Gain', '1/m_B');
body_vel = put(blk, 'simulink/Continuous/Integrator', 'body velocity', [410 70 440 110]);
body_pos = put(blk, 'simulink/Continuous/Integrator', 'body position', [500 70 530 110]);
mux = put(blk, 'simulink/Signal Routing/Mux', 'state mux', [600 160 605 240], 'Inputs', '[3 1 1]', 'DisplayOption', 'bar', 'ShowName', 'off');
out_acc = put(blk, 'simulink/Sinks/Out1', 'z_B_ddot', [680 23 710 37]);
out_wheel = put(blk, 'simulink/Sinks/Out1', 'z_W_ddot', [680 123 710 137], 'Port', '2');
out_x = put(blk, 'simulink/Sinks/Out1', 'x', [680 193 710 207], 'Port', '3');
link_axle(axle, '');
wire(blk, in_zdot, 1, axle, 1, 'zdot');
wire(blk, body_vel, 1, axle, 2);
wire(blk, axle, 1, inv_m, 1, 'F_S');
wire(blk, inv_m, 1, body_vel, 1, 'z_B_ddot');
wire(blk, inv_m, 1, out_acc, 1);
wire(blk, body_vel, 1, body_pos, 1, 'v_B');
wire(blk, axle, 2, out_wheel, 1, 'z_W_ddot');
wire(blk, axle, 3, mux, 1);
wire(blk, body_vel, 1, mux, 2);
wire(blk, body_pos, 1, mux, 3, 'z_B');
wire(blk, mux, 1, out_x, 1, 'x');
note(blk, [30 20], 'SI units. Body velocity v_B [m/s], body position z_B [m], accelerations [m/s^2].');
mask = Simulink.Mask.create(blk);
mask.Type = 'Quarter-car';
mask.Description = ['Quarter-car ride model: one axle under a quarter of the body, heave only. ', ...
    'Input: road height rate under the wheel [m/s]. Outputs: body and wheel vertical acceleration [m/s^2] ', ...
    'and the states x = [tyre deflection; wheel velocity; suspension deflection; body velocity; body position]. ', ...
    'Defaults come from data/models/quartercar/params.json.'];
mask.addDialogControl('Type', 'group', 'Name', 'body_group', 'Prompt', 'Body');
mask.addDialogControl('Type', 'group', 'Name', 'axle_group', 'Prompt', 'Axle');
mask.addParameter('Name', 'm_B', 'Prompt', 'Body mass m_B [kg]', 'Value', num2str(P.m_B, 17), 'Container', 'body_group');
add_axle_parameters(mask, '', axle_values(P), 'axle_group');
mask.Display = sprintf('port_label(''input'', 1, ''zdot'');\nport_label(''output'', 1, ''z_B_ddot'');\nport_label(''output'', 2, ''z_W_ddot'');\nport_label(''output'', 3, ''x'');');
end

function link_axle(axle, prefix)
names = axle_parameter_names();
args = cell(1, 2 * numel(names));
for i = 1:numel(names)
    args{2 * i - 1} = names{i};
    args{2 * i} = [prefix names{i}];
end
set_param(axle, args{:});
end

function add_halfcar(blk, position, P)
new_subsystem(blk, position);
in_f = put(blk, 'simulink/Sources/In1', 'zdot_f', [20 63 50 77]);
in_r = put(blk, 'simulink/Sources/In1', 'zdot_r', [20 263 50 277], 'Port', '2');
in_a = put(blk, 'simulink/Sources/In1', 'a_x', [20 423 50 437], 'Port', '3');
front = put(blk, 'ride_lib/Axle', 'front axle', [120 50 220 150]);
rear = put(blk, 'ride_lib/Axle', 'rear axle', [120 250 220 350]);
link_axle(front, 'front_');
link_axle(rear, 'rear_');
heave_sum = put(blk, 'simulink/Math Operations/Sum', 'heave force', [300 145 320 175], 'Inputs', '++', 'IconShape', 'round', 'ShowName', 'off');
inv_m = put(blk, 'simulink/Math Operations/Gain', 'inverse body mass', [370 145 420 175], 'Gain', '1/m_B');
body_vel = put(blk, 'simulink/Continuous/Integrator', 'body velocity', [480 140 510 180]);
body_pos = put(blk, 'simulink/Continuous/Integrator', 'body position', [570 140 600 180]);
lr_Fr = put(blk, 'simulink/Math Operations/Gain', 'l_r', [300 295 350 325], 'Gain', 'l_r');
lf_Ff = put(blk, 'simulink/Math Operations/Gain', 'l_f', [300 335 350 365], 'Gain', 'l_f');
h_T = put(blk, 'simulink/Sources/Constant', 'h_T', [140 395 190 415], 'Value', 'h_T');
h_B = put(blk, 'simulink/Sources/Constant', 'h_B', [140 455 190 475], 'Value', 'h_B');
height = put(blk, 'simulink/Signal Routing/Switch', 'pitch centre height', [240 405 270 465], 'Criteria', 'u2 > Threshold', 'Threshold', '0');
transfer = put(blk, 'simulink/Math Operations/Product', 'h a', [320 410 350 440]);
m_tot = put(blk, 'simulink/Math Operations/Gain', 'm_tot', [380 410 430 440], 'Gain', 'm_tot');
moment = put(blk, 'simulink/Math Operations/Sum', 'pitch moment', [480 330 500 370], 'Inputs', '+--', 'IconShape', 'round', 'ShowName', 'off');
inv_I = put(blk, 'simulink/Math Operations/Gain', 'inverse pitch inertia', [540 335 590 365], 'Gain', '1/I_B');
pitch_rate = put(blk, 'simulink/Continuous/Integrator', 'pitch rate', [640 330 670 370]);
pitch = put(blk, 'simulink/Continuous/Integrator', 'pitch angle', [730 330 760 370]);
lf_w = put(blk, 'simulink/Math Operations/Gain', 'l_f w', [570 215 620 245], 'Gain', 'l_f');
lr_w = put(blk, 'simulink/Math Operations/Gain', 'l_r w', [570 255 620 285], 'Gain', 'l_r');
cv_f = put(blk, 'simulink/Math Operations/Sum', 'front corner velocity', [680 205 700 235], 'Inputs', '+-', 'IconShape', 'round', 'ShowName', 'off');
cv_r = put(blk, 'simulink/Math Operations/Sum', 'rear corner velocity', [680 255 700 285], 'Inputs', '++', 'IconShape', 'round', 'ShowName', 'off');
mux = put(blk, 'simulink/Signal Routing/Mux', 'state mux', [840 380 845 520], 'Inputs', '[3 3 1 1 1 1]', 'DisplayOption', 'bar', 'ShowName', 'off');
out_zb = put(blk, 'simulink/Sinks/Out1', 'z_B_ddot', [900 103 930 117]);
out_phi = put(blk, 'simulink/Sinks/Out1', 'phi_ddot', [900 293 930 307], 'Port', '2');
out_wf = put(blk, 'simulink/Sinks/Out1', 'z_Wf_ddot', [900 33 930 47], 'Port', '3');
out_wr = put(blk, 'simulink/Sinks/Out1', 'z_Wr_ddot', [900 563 930 577], 'Port', '4');
out_x = put(blk, 'simulink/Sinks/Out1', 'x', [900 443 930 457], 'Port', '5');
wire(blk, in_f, 1, front, 1, 'zdot_f');
wire(blk, in_r, 1, rear, 1, 'zdot_r');
wire(blk, cv_f, 1, front, 2, 'v_corner,f');
wire(blk, cv_r, 1, rear, 2, 'v_corner,r');
wire(blk, front, 1, heave_sum, 1, 'F_S,f');
wire(blk, rear, 1, heave_sum, 2, 'F_S,r');
wire(blk, heave_sum, 1, inv_m, 1);
wire(blk, inv_m, 1, body_vel, 1, 'z_B_ddot');
wire(blk, inv_m, 1, out_zb, 1);
wire(blk, body_vel, 1, body_pos, 1, 'v_B');
wire(blk, rear, 1, lr_Fr, 1);
wire(blk, front, 1, lf_Ff, 1);
wire(blk, h_T, 1, height, 1);
wire(blk, in_a, 1, height, 2, 'a_x');
wire(blk, h_B, 1, height, 3);
wire(blk, height, 1, transfer, 1, 'h');
wire(blk, in_a, 1, transfer, 2);
wire(blk, transfer, 1, m_tot, 1);
wire(blk, lr_Fr, 1, moment, 1);
wire(blk, lf_Ff, 1, moment, 2);
wire(blk, m_tot, 1, moment, 3);
wire(blk, moment, 1, inv_I, 1, 'M_y');
wire(blk, inv_I, 1, pitch_rate, 1, 'phi_ddot');
wire(blk, inv_I, 1, out_phi, 1);
wire(blk, pitch_rate, 1, pitch, 1, 'phi_dot');
wire(blk, pitch_rate, 1, lf_w, 1);
wire(blk, pitch_rate, 1, lr_w, 1);
wire(blk, body_vel, 1, cv_f, 1);
wire(blk, lf_w, 1, cv_f, 2);
wire(blk, body_vel, 1, cv_r, 1);
wire(blk, lr_w, 1, cv_r, 2);
wire(blk, front, 2, out_wf, 1, 'z_Wf_ddot');
wire(blk, rear, 2, out_wr, 1, 'z_Wr_ddot');
wire(blk, rear, 3, mux, 1);
wire(blk, front, 3, mux, 2);
wire(blk, body_vel, 1, mux, 3);
wire(blk, pitch_rate, 1, mux, 4);
wire(blk, body_pos, 1, mux, 5, 'z_B');
wire(blk, pitch, 1, mux, 6, 'phi');
wire(blk, mux, 1, out_x, 1, 'x');
note(blk, [30 0], 'SI units. Pitch angle phi [rad], positive nose down; pitch moment M_y [N m]; a_x [m/s^2], positive when speeding up.');
mask = Simulink.Mask.create(blk);
mask.Type = 'Half-car';
mask.Description = ['Half-car ride model: two axles, body heave and pitch, load transfer from the longitudinal ', ...
    'acceleration a_x (pitch centre at h_T when a_x > 0, at h_B otherwise). Inputs: road height rate under the ', ...
    'front and the rear wheel [m/s] and a_x [m/s^2]. Outputs: body heave and pitch acceleration, front and rear ', ...
    'wheel acceleration, and x = [rear tyre deflection; rear wheel velocity; rear suspension deflection; ', ...
    'front tyre deflection; front wheel velocity; front suspension deflection; body velocity; pitch rate; ', ...
    'body position; pitch angle]. Defaults come from data/models/halfcar/params.json.'];
mask.addDialogControl('Type', 'group', 'Name', 'body_group', 'Prompt', 'Body');
mask.addDialogControl('Type', 'group', 'Name', 'front_group', 'Prompt', 'Front axle');
mask.addDialogControl('Type', 'group', 'Name', 'rear_group', 'Prompt', 'Rear axle');
body = {'m_B', 'Body mass m_B [kg]'; 'I_B', 'Pitch inertia I_B [kg m^2]'; 'l_f', 'Centre of mass to front axle l_f [m]'; ...
    'l_r', 'Centre of mass to rear axle l_r [m]'; 'h_T', 'Pitch centre height under traction h_T [m]'; ...
    'h_B', 'Pitch centre height under braking h_B [m]'};
for i = 1:size(body, 1)
    mask.addParameter('Name', body{i, 1}, 'Prompt', body{i, 2}, 'Value', num2str(P.body.(body{i, 1}), 17), 'Container', 'body_group');
end
add_axle_parameters(mask, 'front_', axle_values(P.front), 'front_group');
add_axle_parameters(mask, 'rear_', axle_values(P.rear), 'rear_group');
mask.Initialization = 'm_tot = m_B + front_m_W + rear_m_W;';
mask.Display = sprintf(['port_label(''input'', 1, ''zdot_f'');\nport_label(''input'', 2, ''zdot_r'');\n', ...
    'port_label(''input'', 3, ''a_x'');\nport_label(''output'', 1, ''z_B_ddot'');\nport_label(''output'', 2, ''phi_ddot'');\n', ...
    'port_label(''output'', 3, ''z_Wf_ddot'');\nport_label(''output'', 4, ''z_Wr_ddot'');\nport_label(''output'', 5, ''x'');']);
end

function add_road(blk, position)
new_subsystem(blk, position);
in_s = put(blk, 'simulink/Sources/In1', 's', [20 43 50 57]);
in_v = put(blk, 'simulink/Sources/In1', 'v', [20 93 50 107], 'Port', '2');
fn = put(blk, 'simulink/User-Defined Functions/MATLAB Function', 'road height rate', [120 35 240 115]);
out = put(blk, 'simulink/Sinks/Out1', 'zdot', [300 68 330 82]);
set_function(fn, road_code(), {'kind', 'bumps', 'ds', 'dz', 'lag'});
wire(blk, in_s, 1, fn, 1, 's');
wire(blk, in_v, 1, fn, 2, 'v');
wire(blk, fn, 1, out, 1, 'zdot');
mask = Simulink.Mask.create(blk);
mask.Type = 'Road';
mask.Description = ['Road height rate under a wheel that runs lag_m behind the front axle. ', ...
    'road is a terrain struct from ride.core.terrain (a scenario''s road field): a bump list or a measured profile.'];
mask.addParameter('Name', 'road', 'Prompt', 'Terrain struct (scenario.road)', 'Value', 'ride.core.terrain.bumps([20 0.06 2])');
mask.addParameter('Name', 'lag_m', 'Prompt', 'Distance behind the front axle [m]', 'Value', '0');
mask.Initialization = sprintf(['lag = lag_m;\nif strcmp(road.type, ''profile'')\n    kind = 2; ds = road.ds; dz = road.dz(:); bumps = zeros(1, 3);\n', ...
    'else\n    kind = 1; ds = 1; dz = zeros(2, 1); bumps = road.bumps;\n    if isempty(bumps)\n        bumps = zeros(1, 3);\n    end\nend']);
mask.Display = sprintf('disp(''Road'');\nport_label(''input'', 1, ''s'');\nport_label(''input'', 2, ''v'');\nport_label(''output'', 1, ''zdot'');');
end

function add_drive(blk, position)
new_subsystem(blk, position);
source = put(blk, 'simulink/Sources/From Workspace', 'speed', [20 60 110 90], 'VariableName', 'speed_table', ...
    'Interpolate', 'off', 'SampleTime', 'dt', 'OutputAfterFinalValue', 'Holding final value');
distance = put(blk, 'simulink/Continuous/Integrator', 'distance', [200 20 230 60]);
previous = put(blk, 'simulink/Discrete/Unit Delay', 'previous speed', [160 120 200 150], 'InitialCondition', 'speeds(1)', 'SampleTime', 'dt');
change = put(blk, 'simulink/Math Operations/Sum', 'speed change', [250 95 270 125], 'Inputs', '+-', 'IconShape', 'round', 'ShowName', 'off');
rate = put(blk, 'simulink/Math Operations/Gain', 'per step', [310 95 360 125], 'Gain', '1/dt');
out_s = put(blk, 'simulink/Sinks/Out1', 's', [420 33 450 47]);
out_v = put(blk, 'simulink/Sinks/Out1', 'v', [420 68 450 82], 'Port', '2');
out_a = put(blk, 'simulink/Sinks/Out1', 'a_x', [420 103 450 117], 'Port', '3');
wire(blk, source, 1, distance, 1, 'v');
wire(blk, distance, 1, out_s, 1, 's');
wire(blk, source, 1, out_v, 1);
wire(blk, source, 1, change, 1);
wire(blk, source, 1, previous, 1);
wire(blk, previous, 1, change, 2);
wire(blk, change, 1, rate, 1);
wire(blk, rate, 1, out_a, 1, 'a_x');
mask = Simulink.Mask.create(blk);
mask.Type = 'Drive';
mask.Description = ['Speed profile played back in steps of dt: speed v [m/s] held over each step, distance s [m] ', ...
    'and the longitudinal acceleration a_x = (v_k - v_(k-1)) / dt [m/s^2], as in ride.simulate.'];
mask.addParameter('Name', 'speeds', 'Prompt', 'Speed at every step [m/s]', 'Value', '6 * ones(500, 1)');
mask.addParameter('Name', 'dt', 'Prompt', 'Step dt [s]', 'Value', '0.02');
mask.Initialization = 'speed_table = [(0:numel(speeds) - 1)'' * dt, speeds(:)];';
mask.Display = sprintf('disp(''Drive'');\nport_label(''output'', 1, ''s'');\nport_label(''output'', 2, ''v'');\nport_label(''output'', 3, ''a_x'');');
end

function note(sys, position, text)
annotation = Simulink.Annotation(sys, text);
annotation.Position = position;
end

function new_subsystem(blk, position)
add_block('simulink/Ports & Subsystems/Subsystem', blk, 'Position', position);
Simulink.SubSystem.deleteContents(blk);
end

function set_function(blk, code, parameters)
chart = find(sfroot, '-isa', 'Stateflow.EMChart', 'Path', getfullname(blk));
chart.Script = code;
for i = 1:numel(parameters)
    data = chart.find('-isa', 'Stateflow.Data', 'Name', parameters{i});
    data.Scope = 'Parameter';
end
end

function code = spring_code()
code = strjoin({
    'function F = progressive_spring(dz, k_S, dz_S_stat, dz_cmp, dz_rbd, f1_cmp, f2_cmp, f1_rbd, f2_rbd, F_max)'
    'if dz > dz_cmp'
    '    dz_F = dz - dz_cmp;'
    '    F = k_S * (dz_S_stat * f1_cmp * (exp(dz_F * f2_cmp / dz_S_stat) - 1) - dz_F);'
    'elseif dz < -dz_rbd'
    '    dz_F = -dz - dz_rbd;'
    '    F = -k_S * (dz_S_stat * f1_rbd * (exp(dz_F * f2_rbd / dz_S_stat) - 1) - dz_F);'
    'else'
    '    F = 0;'
    '    return'
    'end'
    'F = min(max(F, -F_max), F_max);'
    'end'}, newline);
end

function code = damper_code()
code = strjoin({
    'function F = damper(v_S, d1, z1, d2, z2, v_d, v_z)'
    'k = 50;'
    'w_cmp = 1 / (1 + exp(-k * v_S));'
    'F_base = (w_cmp * d1 + (1 - w_cmp) * z1) * v_S;'
    'w_hc = 1 / (1 + exp(-k * (v_S - v_d)));'
    'F_hc = w_hc * (d2 - d1) * (v_S - v_d);'
    'w_hr = 1 / (1 + exp(-k * (-v_S - v_z)));'
    'F_hr = w_hr * (z2 - z1) * (-v_S - v_z);'
    'F = F_base + F_hc - F_hr;'
    'end'}, newline);
end

function code = road_code()
code = strjoin({
    'function zdot = road_height_rate(s, v, kind, bumps, ds, dz, lag)'
    'x = s - lag;'
    'zdot = 0;'
    'if kind == 1'
    '    for i = 1:size(bumps, 1)'
    '        dx = x - bumps(i, 1);'
    '        L = bumps(i, 3);'
    '        if dx > 0 && dx < L'
    '            zdot = (bumps(i, 2) / 2) * (2 * pi / L) * sin(2 * pi * dx / L) * v;'
    '            return'
    '        end'
    '    end'
    'else'
    '    n = numel(dz);'
    '    pos = x / ds;'
    '    if n >= 2 && pos >= 0 && pos <= n - 1'
    '        i = min(floor(pos), n - 2);'
    '        frac = pos - i;'
    '        zdot = (dz(i + 1) * (1 - frac) + dz(i + 2) * frac) * v;'
    '    end'
    'end'
    'end'}, newline);
end
