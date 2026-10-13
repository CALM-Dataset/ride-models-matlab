function r = run(cfg)
if nargin < 1
    cfg = ride.config();
end
r.cfg = cfg;
r.model = cfg.model;
r.P = ride.load(cfg.model);
r.scenario = ride.scenarios.get(cfg.scenario);
r.road = r.scenario.road;
profile = cfg.drive.profile;
if ischar(profile) || isstring(profile)
    profile = cfg.profiles.(profile);
end
dt = r.P.DT;
duration = cfg.drive.duration_s;
if ischar(duration) || isstring(duration)
    wheelbase = 0;
    if isfield(r.P, 'L')
        wheelbase = r.P.L;
    end
    stop = ride.core.terrain.end_point(r.road, wheelbase);
    all_speeds = ride.profiles.speeds(profile, dt, round(600 / dt), r.scenario);
    k = find(cumsum(all_speeds) * dt >= stop + 5, 1);
    if isempty(k)
        k = numel(all_speeds);
    end
    r.speeds = all_speeds(1:k);
else
    r.speeds = ride.profiles.speeds(profile, dt, round(duration / dt), r.scenario);
end
r.out = ride.simulate(r.model, r.P, r.road, r.speeds);
metrics = {'a_w', 'vdv', 'peak_acc', 'travel_time', 'mean_speed'};
if isfield(cfg, 'metrics')
    metrics = cfg.metrics;
end
r.metrics = ride.metrics.evaluate(r.out, r.P, r.scenario, metrics);
end
