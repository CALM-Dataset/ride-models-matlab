function s = build(cfg)
s.model = cfg.model;
s.P = ride.load(cfg.model);
s.road = ride.core.terrain.bumps(cfg.road.bumps);
n = round(cfg.drive.duration_s / s.P.DT);
s.speeds = ride.scenario.speeds(cfg.profiles.(cfg.drive.profile), s.P.DT, n);
end
