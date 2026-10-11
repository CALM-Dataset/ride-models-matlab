function test_config()
cfg = ride.config();
assert(any(strcmp(cfg.model, {'halfcar', 'quartercar'})), 'the config must name a known model');
assert(isfield(cfg.profiles, cfg.drive.profile), 'the drive profile must exist in the profile library');
other = ride.config('model', 'quartercar', 'render.speed', 2);
assert(strcmp(other.model, 'quartercar') && other.render.speed == 2, 'overrides must replace values');
again = ride.config();
assert(strcmp(cfg.model, again.model), 'overrides must not leak into the next call');
dt = 0.02;
flat = ride.scenario.speeds(struct('type', 'constant', 'speed_mps', 6), dt, 100);
assert(all(flat == 6), 'a constant profile must be constant');
dip = ride.scenario.speeds(struct('type', 'dip', 'speed_mps', 6, 'depth_mps', 3, 'center_s', 1, 'width_s', 0.5), dt, 200);
assert(max(dip) <= 6 && min(dip) < 6, 'a dip must slow the car and never speed it up');
s = ride.scenario.run(ride.config('drive.duration_s', 2));
assert(numel(s.out.t) == numel(s.speeds), 'the simulation must cover every speed step');
end
