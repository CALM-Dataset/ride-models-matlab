function test_quartercar_simulink()
here = fileparts(mfilename('fullpath'));
addpath(fullfile(here, '..', 'src'));
addpath(here);
P = ride.models.quartercar.params.load();
files = dir(fullfile(ride.root(), 'data', 'models', 'quartercar', 'reference', '*.json'));
for i = 1:numel(files)
    ref = jsondecode(fileread(fullfile(files(i).folder, files(i).name)));
    road = ride.core.terrain.bumps(ref.road.bumps);
    speeds = ref.drive.speed_mps(:);
    mdl = build_quartercar(P, road, speeds);
    out = sim(mdl, 'ReturnWorkspaceOutputs', 'on');
    acc = out.get('acc_out');
    expected = ref.expected.body.heave_acc_mps2(:);
    err = max(abs(acc(2:numel(speeds) + 1) - expected)) / max(abs(expected));
    fprintf('%-40s z_B_ddot %.2e\n', ref.name, err);
    assert(err < 1e-3, 'Simulink body acceleration differs from the reference');
    close_system(mdl, 0);
end
fprintf('simulink checks passed\n');
end
