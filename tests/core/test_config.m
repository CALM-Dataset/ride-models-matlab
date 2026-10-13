function test_config()
cfg = ride.config();
assert(any(strcmp(cfg.model, ride.models.list())), 'the config must name a known model');
assert(isfield(cfg.profiles, cfg.drive.profile), 'the drive profile must exist in the profile library');
other = ride.config('model', 'quartercar', 'render.speed', 2);
assert(strcmp(other.model, 'quartercar') && other.render.speed == 2, 'overrides must replace values');
again = ride.config();
assert(strcmp(cfg.model, again.model), 'overrides must not leak into the next call');
r = ride.run(ride.config('drive.duration_s', 3));
assert(numel(r.out.t) == numel(r.speeds), 'the simulation must cover every speed step');
assert(isfield(r.metrics, 'a_w'), 'a run must report the configured metrics');
auto = ride.run(cfg);
assert(auto.out.s(end) >= ride.core.terrain.end_point(auto.road, 0), 'an automatic duration must reach the end of the road');
end
