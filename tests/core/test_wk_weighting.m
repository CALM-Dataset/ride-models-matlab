function test_wk_weighting()
dt = 0.02;
y = ride.core.comfort.wk_weight(3.0 * ones(2000, 1), dt);
assert(max(abs(y(100:1900))) < 1e-3, 'Wk must reject a constant offset');
t = (0:dt:20 - dt)';
y4 = ride.core.comfort.wk_weight(sin(2 * pi * 4 * t), dt);
y01 = ride.core.comfort.wk_weight(sin(2 * pi * 0.1 * t), dt);
assert(ride.core.comfort.rms(y4(200:end)) > 5 * ride.core.comfort.rms(y01(200:end)), ...
    'Wk must weight 4 Hz above 0.1 Hz');
iso_hz = [1 4 6.3 8];
iso_db = [-6.33 -0.29 0.46 0.31];
t = (0:dt:30 - dt)';
settled = t >= 15;
for i = 1:numel(iso_hz)
    x = sin(2 * pi * iso_hz(i) * t);
    w = ride.core.comfort.wk_weight(x, dt);
    gain_db = 20 * log10(ride.core.comfort.rms(w(settled)) / ride.core.comfort.rms(x(settled)));
    assert(abs(gain_db - iso_db(i)) < 0.1, 'Wk gain at %.1f Hz is %.2f dB, ISO 2631-1 gives %.2f dB', ...
        iso_hz(i), gain_db, iso_db(i));
end
end
