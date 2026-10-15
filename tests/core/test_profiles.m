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
sv = ride.scenarios.get('synthetic:sv');
s_ = ride.scenarios.get('synthetic:s');
flat_speeds = ride.profiles.speeds(struct('type', 'reactive'), dt, 1000, flat_road);
assert(all(abs(flat_speeds - flat_road.speed_mps) < 1e-12), 'the reactive driver must hold speed on a flat road');
severe = ride.profiles.speeds(struct('type', 'reactive'), dt, 1500, sv);
mild = ride.profiles.speeds(struct('type', 'reactive'), dt, 1500, s_);
assert(max(severe) <= sv.speed_mps + 1e-12 && min(severe) >= 8 / 3.6 - 1e-12, 'the reactive driver must stay within its speed limits');
assert(min(severe) < min(mild) && min(mild) < sv.speed_mps, 'a steeper bump must be taken slower');
assert(abs(severe(end) - sv.speed_mps) < 1e-12, 'the reactive driver must speed up again after the bump');
hole = ride.profiles.speeds(struct('type', 'reactive'), dt, 1500, ride.scenarios.get('synthetic:hs'));
assert(min(hole) < ride.scenarios.get('synthetic:hs').speed_mps, 'the reactive driver must also slow for a hole');
fixture = fullfile(fileparts(mfilename('fullpath')), '..', 'fixtures', 'recorded_profile.json');
recorded = jsondecode(fileread(fixture));
human = ride.profiles.speeds(struct('type', 'human', 'file', fixture), dt, 150, sc);
assert(max(abs(human(1:100) - recorded.sources.human.v_mps)) < 1e-12, 'a recorded profile must replay its samples');
assert(all(human(101:end) == human(100)), 'a recorded profile must hold its last speed after it ends');
coarse = ride.profiles.speeds(struct('type', 'recorded', 'source', 'mpc', 'file', fixture), 2 * dt, 40, sc);
assert(max(abs(coarse - recorded.sources.mpc.v_mps(2:2:80))) < 1e-12, 'a recorded profile must resample to another time step');
mpc_v = ride.profiles.speeds(struct('type', 'mpc', 'file', fixture), dt, 10, sc);
assert(max(abs(mpc_v - recorded.sources.mpc.v_mps(1:10))) < 1e-12, 'the mpc type must read the mpc source');
assert(throws(@() ride.profiles.speeds(struct('type', 'recorded', 'source', 'ppo', 'file', fixture), dt, 10, sc)), 'a missing source must be an error');
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

function tf = throws(fn)
tf = false;
try
    fn();
catch
    tf = true;
end
end
