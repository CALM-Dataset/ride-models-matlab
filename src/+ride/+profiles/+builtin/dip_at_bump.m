function v = dip_at_bump(profile, dt, n, sc)
speed = profile.speed_mps;
if ischar(speed) || isstring(speed)
    speed = sc.speed_mps;
end
x0 = 0;
if ~isempty(sc.road.bumps)
    x0 = min(sc.road.bumps(:, 1));
end
center = max(x0 - profile.lead_m, 0) / speed;
t = (1:n)' * dt;
v = speed - profile.depth_mps * exp(-((t - center) .^ 2) / (2 * profile.width_s ^ 2));
end
