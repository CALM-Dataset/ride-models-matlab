run(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'setup.m'));

ride.profiles.register('creep', @creep_over_bumps);

cfg = ride.config('model', 'halfcar', 'scenario', 'synthetic:m_m');
cfg.profiles.creep = struct('type', 'creep', 'cruise_mps', 8, 'creep_mps', 3, 'margin_m', 5);
cfg.drive.profile = 'creep';
r = ride.run(cfg);
fprintf('creep: a_w %.3f m/s^2, trip %.1f s, slowest %.1f km/h\n', r.metrics.a_w, r.metrics.travel_time, 3.6 * min(r.speeds));

function v = creep_over_bumps(profile, dt, n, sc)
v = zeros(n, 1);
s = 0;
bumps = sc.road.bumps;
for k = 1:n
    near = any(s >= bumps(:, 1) - profile.margin_m & s <= bumps(:, 1) + bumps(:, 3) + profile.margin_m);
    v(k) = profile.cruise_mps;
    if near
        v(k) = profile.creep_mps;
    end
    s = s + v(k) * dt;
end
end
