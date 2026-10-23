function test_validation()
work = tempname;
cleanup = onCleanup(@() rmdir(work, 's'));
[window, scenario_file, truth] = synthetic_recording(fullfile(work, 'sequences', 'testtown', 'testtown_sb01'), ...
    fullfile(work, 'scenarios'));

x = (0:0.02:3)';
d = ride.validation.savgol_derivative(2 * x .^ 3 - x + 1, 51, 3, 0.02);
assert(max(abs(d - (6 * x .^ 2 - 1))) < 1e-8, 'the Savitzky-Golay slope of a cubic must be exact, edges included');

wheels = ride.validation.read_wheel_excitement(fullfile(window, 'export', 'wheel_excitement.json'));
direct = jsondecode(fileread(fullfile(window, 'export', 'wheel_excitement.json')));
table = direct.wheel_results.cariad_wheel_RR.wheel_excitement;
assert(isequal(fieldnames(wheels), {'FL'; 'FR'; 'RL'; 'RR'}), 'all four wheels must be read');
assert(max(abs(wheels.RR.s - table(:, 3))) < 1e-12 && max(abs(wheels.RR.z - table(:, 4))) < 1e-12, ...
    'the fast reader must return the same numbers as jsondecode');

rec = ride.validation.load_recording(window);
assert(max(abs(rec.v - truth.speed)) < 1e-6, 'the human speed of a constant drive must be that speed');
assert(abs(rec.accel_mean(3) - 9.81) < 0.05 && abs(mean(rec.a_z)) < 1e-12, 'gravity must be removed from the IMU');
assert(abs(rec.imu_dt - 0.004) < 1e-9, 'the IMU interval must be read from the timestamps');
anchor_gap = interp1(rec.t, rec.s, rec.meta.anchor_t) + rec.s0 - rec.meta.s_bump;
assert(abs(anchor_gap) < 1e-6, 'the bump position of meta.yaml must match the wheel distance');

c = ride.validation.compare(rec, scenario_file);
assert(abs(c.error) < 0.02, 'a recording made from the simulation must give the same a_w, got %.3f', c.error);
assert(abs(c.lag_s) <= 0.02 && c.correlation > 0.99, 'a recording made from the simulation must line up in time');
shifted = ride.validation.compare(rec, scenario_file, 'offset_m', 0);
assert(shifted.lag_s >= 0.4, 'ignoring the trimmed start must make the measurement lag the simulation');

windows = ride.validation.find_windows(fullfile(work, 'sequences'));
assert(isKey(windows, 'testtown_sb01'), 'recorded windows must be found by scenario name');
list = ride.validation.find_scenarios(fullfile(work, 'scenarios'));
assert(height(list) == 1 && list.paper_split == "eval" && list.region == "germany" && ~list.low_confidence, ...
    'scenario files must be listed with their region, split and confidence');
end

function [window, scenario_file, truth] = synthetic_recording(window, scenarios)
speed = 6;
ds = 0.05;
offset = 3;
bump = [12 0.05 2];
z = ride.core.terrain.height(ride.core.terrain.bumps(bump), (0:ds:40)');
scenario = struct('name', 'testtown_sb01', 'meta', struct('trim', struct('offset_m', offset)), ...
    'road', struct('ds_m', ds, 'z', z), 'bumps', struct('s_start_m', bump(1), 's_end_m', bump(1) + bump(3), ...
    'peak_z_m', bump(2), 'low_confidence', false));
mkdir(fullfile(scenarios, 'germany', 'eval'));
scenario_file = fullfile(scenarios, 'germany', 'eval', 'testtown_sb01.json');
write_json(scenario_file, scenario);
write_text(fullfile(scenarios, 'split.yaml'), sprintf('paper_split:\n  eval:\n    - testtown_sb01\n'));

ts0 = 1000000;
s0 = 50;
t = (0:0.004:6)';
ts = ts0 + round(t * 1e6);
s = s0 + speed * t;
mkdir(fullfile(window, 'export'));
anchor_t = 3;
write_text(fullfile(window, 'meta.yaml'), sprintf(['source_sequence: test\nanchor_ts: %d\ns_bump: %.6f\nwindow:\n  start_ts: %d\n', ...
    '  end_ts: %d\nencounter:\n  start_ts: %d\n  end_ts: %d\nsb_count: 1\n'], ts0 + anchor_t * 1e6, s0 + speed * anchor_t, ...
    ts0, ts(end), ts0 + 2e6, ts0 + anchor_t * 1e6));
road_z = interp1(offset + (0:numel(z) - 1)' * ds, z, s - s0, 'linear', 0);
names = {'FL', 'FR', 'RL', 'RR'};
fid = fopen(fullfile(window, 'export', 'wheel_excitement.json'), 'w');
fprintf(fid, '{"wheel_results": {');
for w = 1:4
    fprintf(fid, '"cariad_wheel_%s": {"contact_point_trajectory": {"invL": 1, "invL_rot": [0, 0, 0], "poses": [', names{w});
    fprintf(fid, '%s', strjoin(arrayfun(@(k) sprintf('[%d, [%.6f, %.6f, 0.0, 0.0, 0.0, 0.0, 1.0]]', ts(k), s(k), w), ...
        1:numel(ts), 'UniformOutput', false), ', '));
    fprintf(fid, ']}, "wheel_excitement": [');
    fprintf(fid, '%s', strjoin(arrayfun(@(k) sprintf('[%d, 1434900000000000, %.6f, %.6f]', ts(k), s(k), road_z(k)), ...
        1:numel(ts), 'UniformOutput', false), ', '));
    fprintf(fid, ']}');
    if w < 4
        fprintf(fid, ', ');
    end
end
fprintf(fid, '}}');
fclose(fid);

P = ride.load('halfcar');
grid = (0:0.02:t(end))';
truth.speed = speed * ones(size(grid));
road = ride.core.terrain.profile(interp1(offset + (0:numel(z) - 1)' * ds, z, (0:ds:60)', 'linear', 0), ds);
out = ride.simulate('halfcar', P, road, truth.speed(1:end - 1));
imu_t = (0:0.004:t(end))';
a_z = 9.81 + interp1([0; out.t], [0; out.z_B_ddot], imu_t, 'pchip', 0);
records = struct('accel_x', num2cell(0.1 * ones(size(imu_t))), 'accel_y', 0, 'accel_z', num2cell(a_z), ...
    'gyro_x', 0, 'gyro_y', 0, 'gyro_z', 0, 'timestamp', num2cell(ts0 + round(imu_t * 1e6)));
write_json(fullfile(window, 'export', 'output.laz.sensor_export.json'), struct('gps', [], 'imu', records));
end

function write_json(file, value)
write_text(file, jsonencode(value));
end

function write_text(file, text)
fid = fopen(file, 'w');
fprintf(fid, '%s', text);
fclose(fid);
end
