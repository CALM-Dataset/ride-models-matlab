function test_quartercar_reference()
P = ride.models.quartercar.params.load();
files = dir(fullfile(ride.root(), 'data', 'models', 'quartercar', 'reference', '*.json'));
assert(~isempty(files), 'no reference cases found');
for i = 1:numel(files)
    ref = jsondecode(fileread(fullfile(files(i).folder, files(i).name)));
    road = ride.core.terrain.bumps(ref.road.bumps);
    out = ride.models.quartercar.sim.simulate(P, road, ref.drive.speed_mps(:));
    body = ref.expected.body.heave_acc_mps2;
    wheel = ref.expected.wheels.acc_mps2;
    err_zb = max(abs(out.z_B_ddot - body(:))) / max(abs(body));
    err_zw = max(abs(out.z_W_ddot - wheel(:))) / max(abs(wheel));
    err_aw = abs(ride.core.comfort.a_w(out.z_B_ddot, P.DT) - ref.expected.weighted_rms_mps2) / ref.expected.weighted_rms_mps2;
    fprintf('%-40s z_B_ddot %.2e  z_W_ddot %.2e  a_w %.2e\n', ref.name, err_zb, err_zw, err_aw);
    assert(err_zb < 1e-6, 'body acceleration differs from the reference');
    assert(err_zw < 1e-6, 'wheel acceleration differs from the reference');
    assert(err_aw < 0.02, 'weighted acceleration differs from the reference');
end
end
