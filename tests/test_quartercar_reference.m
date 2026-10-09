function test_quartercar_reference()
here = fileparts(mfilename('fullpath'));
P = quartercar.params.load();
files = dir(fullfile(here, '..', 'data', 'quartercar', 'reference', '*.json'));
assert(~isempty(files), 'no reference cases found');
for i = 1:numel(files)
    ref = jsondecode(fileread(fullfile(files(i).folder, files(i).name)));
    road = terrain.bumps(ref.bumps);
    out = quartercar.sim.simulate(P, road, ref.speed(:));
    err_zb = max(abs(out.z_B_ddot - ref.z_B_ddot(:))) / max(abs(ref.z_B_ddot));
    err_zw = max(abs(out.z_W_ddot - ref.z_W_ddot(:))) / max(abs(ref.z_W_ddot));
    err_aw = abs(comfort.a_w(out.z_B_ddot, P.DT) - ref.a_w_rms) / ref.a_w_rms;
    fprintf('%-40s z_B_ddot %.2e  z_W_ddot %.2e  a_w %.2e\n', ref.name, err_zb, err_zw, err_aw);
    assert(err_zb < 1e-6, 'body acceleration differs from the reference');
    assert(err_zw < 1e-6, 'wheel acceleration differs from the reference');
    assert(err_aw < 0.02, 'weighted acceleration differs from the reference');
end
end
