function test_profiles()
dt = 0.02;
sc = ride.scenarios.get('synthetic:m');
flat = ride.profiles.speeds(struct('type', 'constant', 'speed_mps', 6), dt, 100, sc);
assert(all(flat == 6), 'a constant profile must be constant');
from_scenario = ride.profiles.speeds(struct('type', 'constant', 'speed_mps', 'scenario'), dt, 10, sc);
assert(all(from_scenario == sc.speed_mps), 'the scenario speed must be usable as the base speed');
dip = ride.profiles.speeds(struct('type', 'dip', 'speed_mps', 6, 'depth_mps', 3, 'center_s', 1, 'width_s', 0.5), dt, 200, sc);
assert(max(dip) <= 6 && min(dip) < 6, 'a dip must slow the car and never speed it up');
before = ride.profiles.speeds(struct('type', 'dip_at_bump', 'speed_mps', 6, 'depth_mps', 3, 'lead_m', 8, 'width_s', 1), dt, 1000, sc);
[~, slowest] = min(before);
distance = cumsum(before) * dt;
assert(distance(slowest) < sc.road.bumps(1, 1), 'the dip must be deepest before the bump');
flat_road = ride.scenarios.make('flat', ride.core.terrain.from_function(@(s) 0 * s, 30, 0.05));
none = ride.profiles.speeds(struct('type', 'dip_at_bump', 'speed_mps', 6, 'depth_mps', 3, 'lead_m', 8, 'width_s', 1), dt, 50, flat_road);
assert(numel(none) == 50 && all(isfinite(none)), 'a dip profile must still work on a road without labelled bumps');
up = ride.profiles.speeds(struct('type', 'ramp', 'from_mps', 4, 'to_mps', 8, 'start_s', 1, 'duration_s', 2), dt, 300, sc);
assert(all(diff(up) >= 0) && up(1) == 4 && up(end) == 8, 'a ramp must climb from its start to its end speed');
table_v = ride.profiles.speeds(struct('type', 'table', 't_s', [0 2 4], 'v_mps', [3 6 3]), dt, 200, sc);
assert(abs(table_v(100) - 6) < 0.1 && abs(table_v(1) - 3) < 0.1, 'a table profile must interpolate its points');
handled = ride.profiles.speeds(struct('type', 'handle', 'fn', @(t) 5 + 0 * t), dt, 10, sc);
assert(all(handled == 5), 'a function profile must follow its function');
ride.profiles.register('double', @(p, dt, n, sc) 2 * p.speed_mps * ones(n, 1));
assert(all(ride.profiles.speeds(struct('type', 'double', 'speed_mps', 3), dt, 5, sc) == 6), 'a registered profile type must be usable');
assert(any(strcmp(ride.profiles.list(), 'double')), 'a registered profile type must be listed');
try
    ride.profiles.speeds(struct('type', 'no_such_profile'), dt, 5, sc);
    failed = false;
catch
    failed = true;
end
assert(failed, 'an unknown profile type must be an error');
end
