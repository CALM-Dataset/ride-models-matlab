function v = ramp(profile, dt, n, sc)
t = (1:n)' * dt;
frac = min(max((t - profile.start_s) / profile.duration_s, 0), 1);
v = profile.from_mps + (profile.to_mps - profile.from_mps) * frac;
end
