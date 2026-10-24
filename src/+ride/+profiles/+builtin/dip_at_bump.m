function v = dip_at_bump(profile, dt, n, sc)
speed = profile.speed_mps;
if ischar(speed) || isstring(speed)
    speed = sc.speed_mps;
end
x0 = 0;
if ~isempty(sc.road.bumps)
    x0 = min(sc.road.bumps(:, 1));
end
center = max(x0 - profile.lead_m, 0);
width = profile.width_s * speed;
v = zeros(n, 1);
s = 0;
for k = 1:n
    v(k) = speed - profile.depth_mps * exp(-((s - center) ^ 2) / (2 * width ^ 2));
    s = s + v(k) * dt;
end
end
