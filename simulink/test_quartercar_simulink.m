function test_quartercar_simulink()
here = fileparts(mfilename('fullpath'));
addpath(here);
addpath(fullfile(here, '..', 'src'));
P = ride.models.quartercar.params.load();
mdl = build_harness('ride_check_quartercar', 'quartercar');
cleanup = onCleanup(@() close_system(mdl, 0));
files = dir(fullfile(ride.root(), 'data', 'models', 'quartercar', 'reference', '*.json'));
assert(~isempty(files), 'no reference cases found');
for i = 1:numel(files)
    ref = jsondecode(fileread(fullfile(files(i).folder, files(i).name)));
    speeds = ref.drive.speed_mps(:);
    n = numel(speeds);
    road = ride.core.terrain.bumps(ref.road.bumps);
    assignin('base', 'ride_road', road);
    assignin('base', 'ride_speeds', speeds);
    assignin('base', 'ride_dt', P.DT);
    assignin('base', 'ride_dt_sim', P.DT_SIM);
    out = sim(mdl);
    body = out.get('z_B_ddot');
    wheel = out.get('z_W_ddot');
    err_zb = relative_error(body(2:n + 1), ref.expected.body.heave_acc_mps2(:));
    err_zw = relative_error(wheel(2:n), next_step_wheel_acc(ref.expected.wheels.acc_mps2(:), road, speeds, P));
    fprintf('%-40s z_B_ddot %.2e  z_W_ddot %.2e\n', ref.name, err_zb, err_zw);
    assert(err_zb < 1e-9, 'Simulink body acceleration differs from the reference');
    assert(err_zw < 1e-9, 'Simulink wheel acceleration differs from the reference');
end
fprintf('quarter-car Simulink checks passed\n');
end

function e = relative_error(actual, expected)
e = max(abs(actual(:) - expected(:))) / max(abs(expected));
end

function next = next_step_wheel_acc(acc, road, speeds, P)
s = cumsum(speeds(:)) * P.DT;
n = numel(speeds);
shift = zeros(n - 1, 1);
for k = 1:n - 1
    old = ride.core.terrain.height_dot(road, s(k), speeds(k));
    new = ride.core.terrain.height_dot(road, s(k), speeds(k + 1));
    shift(k) = P.c_T * (new - old) / P.m_W;
end
next = acc(1:end - 1) + shift;
end
