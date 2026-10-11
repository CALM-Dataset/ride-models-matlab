function s = run(cfg)
s = ride.scenario.build(cfg);
s.out = ride.simulate(s.model, s.P, s.road, s.speeds);
end
