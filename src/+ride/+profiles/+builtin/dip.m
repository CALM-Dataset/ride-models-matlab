function v = dip(profile, dt, n, sc)
t = (1:n)' * dt;
v = profile.speed_mps - profile.depth_mps * exp(-((t - profile.center_s) .^ 2) / (2 * profile.width_s ^ 2));
end
