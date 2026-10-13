function v = constant(profile, dt, n, sc)
speed = profile.speed_mps;
if ischar(speed) || isstring(speed)
    speed = sc.speed_mps;
end
v = speed * ones(n, 1);
end
