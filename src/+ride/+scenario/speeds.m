function v = speeds(profile, dt, n)
t = (1:n)' * dt;
switch profile.type
    case 'constant'
        v = profile.speed_mps * ones(n, 1);
    case 'dip'
        v = profile.speed_mps - profile.depth_mps * exp(-((t - profile.center_s) .^ 2) / (2 * profile.width_s ^ 2));
    otherwise
        error('ride:unknownProfile', 'unknown speed profile type "%s"', profile.type);
end
end
