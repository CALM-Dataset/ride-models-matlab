run(fullfile(fileparts(mfilename('fullpath')), '..', 'setup.m'));
cfg = ride.config();
cfg.drive.duration_s = cfg.compare.duration_s;
names = cfg.compare.profiles;
for i = 1:numel(names)
    cfg.drive.profile = names{i};
    r = ride.scenario.run(cfg);
    wheelbase = 0;
    if isfield(r.P, 'L')
        wheelbase = r.P.L;
    end
    road_end = max(r.road.bumps(:, 1) + r.road.bumps(:, 3)) + wheelbase;
    k = min([find(r.out.s >= road_end, 1), numel(r.out.t)]);
    fprintf('%-12s travel time %.2f s   weighted RMS %.3f m/s^2\n', names{i}, r.out.t(k), ...
        ride.core.comfort.a_w(r.out.z_B_ddot(1:k), r.P.DT));
end
