function test_halfcar_reference()
P = ride.models.halfcar.params.load();
files = dir(fullfile(ride.root(), 'data', 'models', 'halfcar', 'reference', '*.json'));
assert(~isempty(files), 'no reference cases found');
for i = 1:numel(files)
    ref = jsondecode(fileread(fullfile(files(i).folder, files(i).name)));
    road = ride.core.terrain.bumps(ref.road.bumps);
    out = ride.models.halfcar.sim.simulate(P, road, ref.drive.speed_mps(:));
    body = ref.expected.body;
    err_zb = max(abs(out.z_B_ddot - body.heave_acc_mps2(:))) / max(abs(body.heave_acc_mps2));
    err_phi = max(abs(out.phi_ddot - body.pitch_acc_radps2(:))) / max(abs(body.pitch_acc_radps2));
    err_aw = abs(ride.core.comfort.a_w(out.z_B_ddot, P.DT) - ref.expected.weighted_rms_mps2) / ref.expected.weighted_rms_mps2;
    fprintf('%-40s z_B_ddot %.2e  phi_ddot %.2e  a_w %.2e\n', ref.name, err_zb, err_phi, err_aw);
    assert(err_zb < 1e-6, 'body acceleration differs from the reference');
    assert(err_phi < 1e-6, 'pitch acceleration differs from the reference');
    assert(err_aw < 0.02, 'weighted acceleration differs from the reference');
end
end
