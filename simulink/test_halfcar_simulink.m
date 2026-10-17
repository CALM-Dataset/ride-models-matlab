function test_halfcar_simulink()
here = fileparts(mfilename('fullpath'));
addpath(here);
addpath(fullfile(here, '..', 'src'));
P = ride.models.halfcar.params.load();
mdl = build_harness('ride_check_halfcar', 'halfcar');
cleanup = onCleanup(@() close_system(mdl, 0));
files = dir(fullfile(ride.root(), 'data', 'models', 'halfcar', 'reference', '*.json'));
assert(~isempty(files), 'no reference cases found');
for i = 1:numel(files)
    ref = jsondecode(fileread(fullfile(files(i).folder, files(i).name)));
    speeds = ref.drive.speed_mps(:);
    n = numel(speeds);
    road = ride.core.terrain.bumps(ref.road.bumps);
    set_inputs(road, speeds, P);
    out = sim(mdl);
    heave = out.get('z_B_ddot');
    pitch = out.get('phi_ddot');
    front = out.get('z_Wf_ddot');
    rear = out.get('z_Wr_ddot');
    body = ref.expected.body;
    err_zb = relative_error(heave(2:n + 1), body.heave_acc_mps2(:));
    err_phi = relative_error(pitch(2:n), next_step_pitch_acc(body.pitch_acc_radps2(:), speeds, P));
    err_wf = relative_error(front(2:n), next_step_wheel_acc(ref.expected.wheels.front_acc_mps2(:), road, speeds, P, P.front, 0));
    err_wr = relative_error(rear(2:n), next_step_wheel_acc(ref.expected.wheels.rear_acc_mps2(:), road, speeds, P, P.rear, P.L));
    fprintf('%-40s z_B_ddot %.2e  phi_ddot %.2e  z_Wf_ddot %.2e  z_Wr_ddot %.2e\n', ref.name, err_zb, err_phi, err_wf, err_wr);
    assert(err_zb < 1e-9, 'Simulink body acceleration differs from the reference');
    assert(err_phi < 1e-9, 'Simulink pitch acceleration differs from the reference');
    assert(err_wf < 1e-9 && err_wr < 1e-9, 'Simulink wheel acceleration differs from the reference');
end
fprintf('half-car Simulink checks passed\n');
end

function set_inputs(road, speeds, P)
assignin('base', 'ride_road', road);
assignin('base', 'ride_speeds', speeds);
assignin('base', 'ride_dt', P.DT);
assignin('base', 'ride_dt_sim', P.DT_SIM);
end

function e = relative_error(actual, expected)
e = max(abs(actual(:) - expected(:))) / max(abs(expected));
end

function next = next_step_pitch_acc(phi_ddot, speeds, P)
a = diff([speeds(1); speeds(:)]) / P.DT;
moment = P.m_tot * pitch_centre(a, P.body) .* a / P.body.I_B;
next = phi_ddot(1:end - 1) + moment(1:end - 1) - moment(2:end);
end

function h = pitch_centre(a, body)
h = body.h_B * ones(size(a));
h(a > 0) = body.h_T;
end

function next = next_step_wheel_acc(acc, road, speeds, P, axle, lag)
s = cumsum(speeds(:)) * P.DT;
n = numel(speeds);
shift = zeros(n - 1, 1);
for k = 1:n - 1
    old = ride.core.terrain.height_dot(road, s(k) - lag, speeds(k));
    new = ride.core.terrain.height_dot(road, s(k) - lag, speeds(k + 1));
    shift(k) = axle.c_T * (new - old) / axle.m_W;
end
next = acc(1:end - 1) + shift;
end
